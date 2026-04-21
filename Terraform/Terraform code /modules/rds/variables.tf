variable "environment" {}

variable "private_db_subnet_ids" {
  type = list(string)
}

variable "db_sg_id" {}

variable "instance_class" {
  default = "db.t3.micro"
}

variable "db_name" {}
variable "username" {}
variable "password" {}