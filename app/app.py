from flask import Flask, request, jsonify, render_template_string

import pymysql, boto3, memcache, os, json, uuid
from kafka import KafkaProducer


app = Flask(__name__)


DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")

S3_BUCKET = os.getenv("S3_BUCKET")
MEMCACHED_SERVER = os.getenv("MEMCACHED_SERVER")
KAFKA_SERVER = os.getenv("KAFKA_SERVER")


s3 = boto3.client("s3")

# ================= UI =================

HTML = """

<!DOCTYPE html>

<html>
<head>
<title>DevOps Social Application</title>
<style>
body {
  font-family: Arial;
  background: linear-gradient(to right, #4facfe, #00f2fe);
}
.container {
  width: 400px;
  margin: 40px auto;
  background: white;
  padding: 20px;
  border-radius: 10px;
}
.hidden { display:none; }
input, button {
  width:100%;
  padding:10px;
  margin:5px 0;
}
button {
  background:#007bff;
  color:white;
  border:none;
}
</style>
</head>

<body>

<div class="container" id="auth">
<h2>Register</h2>
<input id="ruser" placeholder="Username">
<input id="rpass" placeholder="Password">
<button onclick="register()">Register</button>

<h2>Login</h2>
<input id="luser" placeholder="Username">
<input id="lpass" placeholder="Password">
<button onclick="login()">Login</button>
</div>

<div class="container hidden" id="dashboard">
<h2>Welcome</h2>
<p id="postCount"></p>

<h3>Create Post</h3>
<input id="content" placeholder="Write post">
<input type="file" id="file">
<button onclick="createPost()">Post</button>

<h3>Response</h3>
<pre id="res"></pre>
</div>

<script>
let token = localStorage.getItem("token") || "";

// REGISTER
function register(){
fetch('/add_user',{method:'POST',headers:{'Content-Type':'application/json'},
body:JSON.stringify({username:ruser.value,password:rpass.value})})
.then(r=>r.json()).then(alert)
}

// LOGIN
function login(){
fetch('/login',{method:'POST',headers:{'Content-Type':'application/json'},
body:JSON.stringify({username:luser.value,password:lpass.value})})
.then(r=>r.json()).then(d=>{
if(d.token){
token=d.token;
localStorage.setItem("token", token);
auth.classList.add("hidden");
dashboard.classList.remove("hidden");
loadProfile();
}
})
}

// LOAD PROFILE
function loadProfile(){
 let token = localStorage.getItem("token");  // 🔥 always fresh

 fetch('/profile?token='+token)
 .then(r=>r.json())
 .then(d=>{
   if(d.post_count !== undefined){
     postCount.innerText = "Total Posts: " + d.post_count;
   } else {
     postCount.innerText = "Session expired";
   }
 })
}

// CREATE POST
function createPost(){
 let token = localStorage.getItem("token");  // 🔥 FIX

 let f=new FormData();
 f.append("token",token);
 f.append("content",content.value);
 f.append("file",file.files[0]);

 fetch('/post',{method:'POST',body:f})
 .then(r=>r.json())
 .then(d=>{
   res.innerText=JSON.stringify(d);
   setTimeout(loadProfile,1000);
 })
}
</script>

</body>
</html>
"""

@app.route("/")
def home():
    return render_template_string(HTML)

# ================= DB =================

def get_db():
    return pymysql.connect(host=DB_HOST,user=DB_USER,password=DB_PASS,database=DB_NAME)

# ================= REGISTER =================

@app.route("/add_user",methods=["POST"])
def add_user():
    d=request.json
    db=get_db(); c=db.cursor()
    c.execute("INSERT INTO users(username,password) VALUES(%s,%s)",(d["username"],d["password"]))
    db.commit(); db.close()
    return jsonify({"msg":"User created"})

# ================= LOGIN =================

@app.route("/login",methods=["POST"])
def login():
    d=request.json
    db=get_db(); c=db.cursor()
    c.execute("SELECT id FROM users WHERE username=%s AND password=%s",(d["username"],d["password"]))
    user=c.fetchone(); db.close()

    if not user:
        return jsonify({"error":"Invalid"}),401

    token=str(uuid.uuid4())
    mc=memcache.Client([MEMCACHED_SERVER])
    mc.set(token,user[0],time=3600)

    print("LOGIN TOKEN:", token)
    return jsonify({"token":token})
    

# ================= PROFILE =================

@app.route("/profile")
def profile():
    token=request.args.get("token")
    mc=memcache.Client([MEMCACHED_SERVER])
    user_id=mc.get(token)

    if not user_id:
        return jsonify({"post_count": 0})

    db=get_db(); c=db.cursor()
    c.execute("SELECT post_count FROM users WHERE id=%s",(user_id,))
    row = c.fetchone()
    count = row[0] if row and row[0] is not None else 0
    db.close()

    return jsonify({"post_count": count if count is not None else 0})


# ================= POST =================

@app.route("/post",methods=["POST"])
def post():
    token=request.form["token"]
    content=request.form["content"]
    file=request.files["file"]

    mc=memcache.Client([MEMCACHED_SERVER])
    user_id=mc.get(token)

    if not user_id:
        return jsonify({"error":"Not logged in"}),401

    filename=str(uuid.uuid4())
    s3.upload_fileobj(file,S3_BUCKET,filename)

    db=get_db(); c=db.cursor()
    c.execute("INSERT INTO posts(user_id,content) VALUES(%s,%s)",(user_id,content))
    db.commit(); db.close()

    producer=KafkaProducer(
        bootstrap_servers=[KAFKA_SERVER],
        value_serializer=lambda v: json.dumps(v).encode()
    )

    producer.send("post-events",{"user_id":user_id})
    producer.flush()

    print("POST TOKEN:", token)
    print("CACHE USER:", user_id)
    return jsonify({"msg":"Post created + Kafka sent"})
    
    







if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
