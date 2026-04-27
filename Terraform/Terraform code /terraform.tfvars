# Common Global Variables 

region      = "ap-south-1"
environment = "poc"

# VPC CONFIG 

vpc_conf = {

  vpc = {
    cidr_vpc = "10.0.0.0/16"

    additional_tags = {
      owner = "rudra"
    }
  }

  nat_gateway = {
    additional_tags = {
      owner = "rudra"
    }
  }

  subnets = {

    public_subnets = {
      cidr = [
        "10.0.0.0/20",
        "10.0.16.0/20",
        "10.0.32.0/20"
      ]

      additional_tags = {
        owner = "rudra"
      }
    }

    private_app_subnets = {
      cidr = [
        "10.0.48.0/20",
        "10.0.64.0/20",
        "10.0.80.0/20"
      ]

      additional_tags = {
        owner = "rudra"
      }
    }

    private_db_subnets = {
      cidr = [
        "10.0.96.0/20",
        "10.0.112.0/20",
        "10.0.128.0/20"
      ]

      additional_tags = {
        owner = "rudra"
      }
    }
  }
}

# S3 

bucket_name = "rudrabucket-12345" 

# ECR 

repo_name = "my-app-repo"

# Kafka 

kafka_ami = "ami-0e12ffc2dd465f6e4"

# RDS 

db_instance_class = "db.t3.micro"
db_name           = "mydb"
db_username       = "admin"
db_password       = "password123"

# Elasticache 

memcached_node_type = "cache.t3.micro"
memcached_nodes     = 2