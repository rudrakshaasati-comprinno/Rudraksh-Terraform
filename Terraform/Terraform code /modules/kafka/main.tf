resource "aws_instance" "kafka" {
  ami           = var.ami
  instance_type = "t3.micro"

  subnet_id              = var.private_app_subnet_ids[0]
  vpc_security_group_ids = [var.kafka_sg_id]

  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              amazon-linux-extras install java-openjdk11 -y

              cd /opt
              wget https://archive.apache.org/dist/kafka/3.5.0/kafka_2.13-3.5.0.tgz
              tar -xzf kafka_2.13-3.5.0.tgz
              mv kafka_2.13-3.5.0 kafka

              PRIVATE_IP=$(curl http://169.254.169.254/latest/meta-data/local-ipv4)

              
              cat <<EOT >> /opt/kafka/config/server.properties

listeners=PLAINTEXT://0.0.0.0:9092
advertised.listeners=PLAINTEXT://$PRIVATE_IP:9092
zookeeper.connect=localhost:2181
EOT

              # Start Zookeeper
              nohup /opt/kafka/bin/zookeeper-server-start.sh /opt/kafka/config/zookeeper.properties > /opt/zookeeper.log 2>&1 &

              sleep 10

              # Start Kafka
              nohup /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/server.properties > /opt/kafka.log 2>&1 &

              EOF

  tags = {
    Name        = "${var.environment}-kafka"
    Environment = var.environment
  }
}