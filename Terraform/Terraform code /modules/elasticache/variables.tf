variable "environment" {}

variable "private_app_subnet_ids" {
  type = list(string)
}

variable "memcached_sg_id" {}

variable "node_type" {}
variable "num_nodes" {}