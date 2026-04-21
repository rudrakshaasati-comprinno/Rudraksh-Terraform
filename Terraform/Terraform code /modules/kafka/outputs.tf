output "kafka_bootstrap_server" {
  value = "${aws_instance.kafka.private_ip}:9092"
}