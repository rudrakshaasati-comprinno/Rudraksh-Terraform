from kafka import KafkaConsumer
import json, pymysql, os

DB_HOST=os.getenv("DB_HOST")
DB_USER=os.getenv("DB_USER")
DB_PASS=os.getenv("DB_PASS")
DB_NAME=os.getenv("DB_NAME")

consumer=KafkaConsumer(
"post-events",
bootstrap_servers=[os.getenv("KAFKA_SERVER")],
value_deserializer=lambda m: json.loads(m.decode())
)

def get_db():
    return pymysql.connect(host=DB_HOST,user=DB_USER,password=DB_PASS,database=DB_NAME)

for msg in consumer:
    user_id=msg.value["user_id"]


    db=get_db(); c=db.cursor()
    c.execute("UPDATE users SET post_count=post_count+1 WHERE id=%s",(user_id,))
    db.commit(); db.close()

    print("Post count updated:",user_id)

