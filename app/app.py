
from flask import Flask, request, jsonify, render_template_string
import pymysql
import boto3
import memcache
from kafka import KafkaProducer
import json
import os

app = Flask(__name__)

# ==============================
# ENV VARIABLES
# ==============================
DB_HOST = os.getenv("DB_HOST")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")
DB_NAME = os.getenv("DB_NAME")

S3_BUCKET = os.getenv("S3_BUCKET")
MEMCACHED_SERVER = os.getenv("MEMCACHED_SERVER")
KAFKA_SERVER = os.getenv("KAFKA_SERVER")

# ==============================
# GLOBAL CLIENTS (SAFE ONLY)
# ==============================
s3 = boto3.client("s3")

# ==============================
# SIMPLE UI
# ==============================
HTML_PAGE = """
<!DOCTYPE html>
<html>
<head>
    <title>AWS DevOps App</title>
</head>
<body style="font-family: Arial; padding: 20px;">
    <h1>🚀 AWS DevOps Demo App</h1>

    <h2>Add User (RDS)</h2>
    <input id="username" placeholder="Enter name">
    <button onclick="addUser()">Add User</button>

    <h2>Get Latest User</h2>
    <button onclick="getUser()">Get User</button>

    <h2>Upload File (S3)</h2>
    <input type="file" id="file">
    <button onclick="uploadFile()">Upload</button>

    <h2>Send Event (Kafka)</h2>
    <input id="event" placeholder="Enter event">
    <button onclick="sendEvent()">Send</button>

    <h2>Response</h2>
    <pre id="output"></pre>

<script>
function addUser() {
    let name = document.getElementById("username").value;
    fetch('/add_user', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({name: name})
    }).then(res => res.json()).then(show);
}

function getUser() {
    fetch('/get_user').then(res => res.json()).then(show);
}

function uploadFile() {
    let file = document.getElementById("file").files[0];
    let formData = new FormData();
    formData.append("file", file);

    fetch('/upload', {
        method: 'POST',
        body: formData
    }).then(res => res.json()).then(show);
}

function sendEvent() {
    let msg = document.getElementById("event").value;
    fetch('/send_event', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({msg: msg})
    }).then(res => res.json()).then(show);
}

function show(data) {
    document.getElementById("output").innerText = JSON.stringify(data, null, 2);
}
</script>
</body>
</html>
"""

@app.route("/")
def ui():
    return render_template_string(HTML_PAGE)

# ==============================
# RDS + MEMCACHED
# ==============================
@app.route("/add_user", methods=["POST"])
def add_user():
    try:
        data = request.json
        name = data.get("name")

        db = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME
        )

        cursor = db.cursor()
        cursor.execute("INSERT INTO users(name) VALUES(%s)", (name,))
        db.commit()
        db.close()

        mc = memcache.Client([MEMCACHED_SERVER], debug=0)
        mc.set("latest_user", name)

        return jsonify({"message": "User added"})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/get_user")
def get_user():
    try:
        mc = memcache.Client([MEMCACHED_SERVER], debug=0)
        cached = mc.get("latest_user")

        if cached:
            return jsonify({"source": "cache", "user": cached})

        db = pymysql.connect(
            host=DB_HOST,
            user=DB_USER,
            password=DB_PASS,
            database=DB_NAME
        )

        cursor = db.cursor()
        cursor.execute("SELECT name FROM users ORDER BY id DESC LIMIT 1")
        result = cursor.fetchone()
        db.close()

        if result:
            mc.set("latest_user", result[0])
            return jsonify({"source": "db", "user": result[0]})

        return jsonify({"message": "No user found"})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ==============================
# S3
# ==============================
@app.route("/upload", methods=["POST"])
def upload_file():
    try:
        file = request.files["file"]
        s3.upload_fileobj(file, S3_BUCKET, file.filename)
        return jsonify({"message": "Uploaded to S3"})
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ==============================
# KAFKA (FIXED 🔥)
# ==============================
@app.route("/send_event", methods=["POST"])
def send_event():
    try:
        if not KAFKA_SERVER:
            return jsonify({"error": "Kafka not configured"}), 500

        data = request.json

        producer = KafkaProducer(
            bootstrap_servers=[KAFKA_SERVER],
            value_serializer=lambda v: json.dumps(v).encode('utf-8')
        )

        producer.send("test-topic", data)
        producer.flush()

        return jsonify({"message": "Event sent"})

    except Exception as e:
        return jsonify({"error": str(e)}), 500


# ==============================
# RUN
# ==============================
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
