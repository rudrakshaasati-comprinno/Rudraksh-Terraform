
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


# VPC

module "vpc" {
  source = "./modules/vpc"
  region = var.region
}


# SECURITY GROUP

module "sg" {
  source = "./modules/security_group"
  vpc_id = local.vpc_id
}


# ALB

module "alb" {
  source            = "./modules/alb"
  vpc_id            = local.vpc_id
  public_subnet_ids = local.public_subnets
  alb_sg_id         = module.sg.alb_sg_id
}


# S3

module "s3" {
  source      = "./modules/s3"
  bucket_name = var.bucket_name
}


# KMS

module "kms" {
  source = "./modules/kms"
}


# ECR

module "ecr" {
  source    = "./modules/ecr"
  repo_name = var.repo_name
}


# KAFKA

module "kafka" {
  source                 = "./modules/kafka"
  private_app_subnet_ids = local.private_app_subnets
  kafka_sg_id            = module.sg.kafka_sg_id
  ami                    = var.kafka_ami
}


# RDS

module "rds" {
  source                = "./modules/rds"
  private_db_subnet_ids = local.private_db_subnets
  db_sg_id              = module.sg.rds_sg_id

  instance_class = var.db_instance_class
  db_name        = var.db_name
  username       = var.db_username
  password       = var.db_password
}


# ELASTICACHE

module "elasticache" {
  source                 = "./modules/elasticache"
  private_app_subnet_ids = local.private_app_subnets
  memcached_sg_id        = module.sg.memcached_sg_id
  node_type              = var.memcached_node_type
  num_nodes              = var.memcached_nodes
}


# ECS

module "ecs" {
  source                 = "./modules/ecs"
  private_app_subnet_ids = local.private_app_subnets
  ecs_sg_id              = module.sg.ecs_sg_id
  container_image        = "${module.ecr.repository_url}:v8"
  target_group_arn       = module.alb.target_group_arn
  db_host                = module.rds.rds_endpoint
  db_user                = var.db_username
  db_pass                = var.db_password
  db_name                = var.db_name
  s3_bucket              = module.s3.bucket_name
  memcached_endpoint     = module.elasticache.memcached_endpoint
  kafka_server           = module.kafka.kafka_bootstrap_server

  depends_on = [
    module.rds,
    module.kafka,
    module.elasticache
  ]
}