output "memcached_endpoint" {
  value = aws_elasticache_cluster.memcached.configuration_endpoint
}