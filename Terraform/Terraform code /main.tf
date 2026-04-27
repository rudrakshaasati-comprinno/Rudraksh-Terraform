
#  Terraform Provider                               


terraform {
  required_version = ">= 0.15.0"

  required_providers {
    aws = {
      version = ">= 4.33.0"
    }
  }
}


#  AWS Provider    


provider "aws" {
  region = var.region
}


#  Local Variables 


locals {
  vpc_id              = module.vpc.vpc_id
  public_subnets      = module.vpc.public_subnets_ids
  private_app_subnets = module.vpc.private_app_subnets_ids
  private_db_subnets  = module.vpc.private_db_subnets_ids
}


#  VPC (Multi-Tier Architecture)
# Creates VPC with three-tier subnet architecture:
# - Public tier: Internet-facing subnets for ALB
# - Application tier: Private subnets for ECS, Kafka, ElastiCache  
# - Database tier: Isolated subnets for RDS databases

module "vpc" {
  source      = "./modules/vpc"
  region      = var.region
  environment = var.environment
  vpc_conf    = var.vpc_conf
}


#  SECURITY GROUP  


module "sg" {
  source      = "./modules/security_group"
  environment = var.environment
  vpc_id      = local.vpc_id
}


#  ALB              


module "alb" {
  source            = "./modules/alb"
  environment       = var.environment
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnets
  alb_sg_id         = module.sg.alb_sg_id
}


#  S3               


module "s3" {
  source      = "./modules/s3"
  environment = var.environment
  bucket_name = var.bucket_name
}


#  KMS              


module "kms" {
  source      = "./modules/kms"
  environment = var.environment
}


#  ECR              


module "ecr" {
  source      = "./modules/ecr"
  environment = var.environment
  repo_name   = var.repo_name
}


#  KAFKA            


module "kafka" {
  source                 = "./modules/kafka"
  environment            = var.environment
  private_app_subnet_ids = local.private_app_subnets
  kafka_sg_id            = module.sg.kafka_sg_id
  ami                    = var.kafka_ami
}


#  RDS              


module "rds" {
  source                = "./modules/rds"
  environment           = var.environment
  private_db_subnet_ids = local.private_db_subnets
  db_sg_id              = module.sg.rds_sg_id

  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password
}


#  ELASTICACHE      


module "elasticache" {
  source                 = "./modules/elasticache"
  environment            = var.environment
  private_app_subnet_ids = local.private_app_subnets

  # ✅ FIX: correct SG name
  memcached_sg_id = module.sg.memcached_sg_id

  node_type = var.memcached_node_type
  num_nodes = var.memcached_nodes
}


#  ECS (APPLICATION)


module "ecs" {
  source                 = "./modules/ecs"
  environment            = var.environment
  private_app_subnet_ids = local.private_app_subnets
  ecs_sg_id              = module.sg.ecs_sg_id

  container_image = "${module.ecr.repository_url}:v8"

  target_group_arn = module.alb.target_group_arn

 
  # APP CONFIG (CRITICAL FIXES)
 
  db_host = module.rds.rds_endpoint
  db_user = var.db_username
  db_pass = var.db_password
  db_name = var.db_name

  
  s3_bucket = module.s3.bucket_name

  memcached_endpoint = module.elasticache.memcached_endpoint
  kafka_server = module.kafka.kafka_bootstrap_server

  
  depends_on = [
    module.rds,
    module.kafka,
    module.elasticache
  ]
}