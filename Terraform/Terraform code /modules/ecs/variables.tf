variable "environment" {}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "ecs_sg_id" {}

variable "container_image" {}

variable "target_group_arn" {}

# ==============================
# APP ENV VARIABLES
# ==============================
variable "db_host" {}
variable "db_user" {}
variable "db_pass" {}
variable "db_name" {}

variable "s3_bucket" {}

variable "memcached_endpoint" {}
variable "kafka_server" {}