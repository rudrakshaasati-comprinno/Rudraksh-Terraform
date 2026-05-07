
resource "aws_elasticache_subnet_group" "memcached" {
  name       = "memcached-subnet"
  subnet_ids = var.private_app_subnet_ids
}


resource "aws_elasticache_cluster" "memcached" {
  cluster_id           = "app-memcached"
  engine               = "memcached"
  node_type            = var.node_type
  num_cache_nodes      = var.num_nodes

  parameter_group_name = "default.memcached1.6"

  subnet_group_name  = aws_elasticache_subnet_group.memcached.name
  security_group_ids = [var.memcached_sg_id]

  port = 11211

  tags = {
    Name = "app-memcached"
  }
}