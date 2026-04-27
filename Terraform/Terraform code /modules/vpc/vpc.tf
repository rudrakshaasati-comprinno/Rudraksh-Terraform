data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "rudra_vpc" {
  cidr_block = var.vpc_conf.vpc.cidr_vpc
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(
              {
              "Name" = "${var.environment}-rudra-vpc"
              "Environment" = var.environment
              },
              var.vpc_conf.vpc.additional_tags
          )
}


resource "aws_subnet" "public_tier_subnets" { 
    count = length( var.vpc_conf.subnets.public_subnets.cidr )
    vpc_id = aws_vpc.rudra_vpc.id
    map_public_ip_on_launch = true
    cidr_block = element(var.vpc_conf.subnets.public_subnets.cidr, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = merge (
    {
      Name = "${var.environment}-public-${count.index + 1}"
      Environment = var.environment
      Tier = "public"
    },
    var.vpc_conf.subnets.public_subnets.additional_tags
  )
}


resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.rudra_vpc.id
  tags = merge(
    {
      "Name" = "${var.environment}-public-rt"
      "Environment" = var.environment
      "Tier" = "public"
    },
  )
}



resource "aws_route" "public_route" {
  route_table_id = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  
  gateway_id = aws_internet_gateway.internet_gateway.id
}



resource "aws_route_table_association" "public_route_association" {
  count = length( var.vpc_conf.subnets.public_subnets.cidr )
  subnet_id = aws_subnet.public_tier_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}



resource "aws_internet_gateway" "internet_gateway" {
  vpc_id = aws_vpc.rudra_vpc.id
  tags = {
    "Name" = "${var.environment}-igw"
    "Environment" = var.environment
    "Type" = "internet_gateway"
  }
}


resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
  tags = {
    "Name" = "${var.environment}-nat-eip"
    "Environment" = var.environment
  }
}


resource "aws_nat_gateway" "nat_gateway_instance" {
  depends_on = [aws_internet_gateway.internet_gateway]
  allocation_id =  aws_eip.nat_gateway_eip.id
  subnet_id = aws_subnet.public_tier_subnets[0].id
  tags = merge(
            {
              "Name" = "${var.environment}-nat-gw"
              "Environment" = var.environment
            },
            var.vpc_conf.nat_gateway.additional_tags
        )
}



resource "aws_subnet" "app_layer_subnets" { 
  count = length( var.vpc_conf.subnets.private_app_subnets.cidr )
  vpc_id = aws_vpc.rudra_vpc.id 
  cidr_block = element(var.vpc_conf.subnets.private_app_subnets.cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge (
    {
      Name = "${var.environment}-app-${count.index + 1}"
      Environment = var.environment
      Tier = "application"
    },
    var.vpc_conf.subnets.private_app_subnets.additional_tags
  )
}


resource "aws_route_table" "app_layer_route_table" {
  vpc_id = aws_vpc.rudra_vpc.id
  tags = merge(
    {
      "Name" = "${var.environment}-app-rt"
      "Environment" = var.environment
      "Tier" = "application"
    },
  )
}


resource "aws_route" "private_route" {
  route_table_id = aws_route_table.app_layer_route_table.id
  destination_cidr_block = "0.0.0.0/0" 
  nat_gateway_id = aws_nat_gateway.nat_gateway_instance.id
}


resource "aws_route_table_association" "app_layer_route_association" {
  count = length(var.vpc_conf.subnets.private_app_subnets.cidr)
  subnet_id = aws_subnet.app_layer_subnets[count.index].id
  route_table_id = aws_route_table.app_layer_route_table.id
}


resource "aws_subnet" "database_layer_subnets" {  
  count = length( var.vpc_conf.subnets.private_db_subnets.cidr )
  vpc_id = aws_vpc.rudra_vpc.id
  cidr_block = element(var.vpc_conf.subnets.private_db_subnets.cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge (
    {
      Name = "${var.environment}-db-${count.index + 1}"
      Environment = var.environment
      Tier = "database"
    },
    var.vpc_conf.subnets.private_db_subnets.additional_tags
  )
}

resource "aws_route_table" "database_layer_route_table" {
  vpc_id = aws_vpc.rudra_vpc.id
  tags = {
      Name = "${var.environment}-db-rt"
      Environment = var.environment
      Tier = "database"
    }
}

resource "aws_route_table_association" "database_layer_route_association" {
  count = length( var.vpc_conf.subnets.private_db_subnets.cidr )
  subnet_id = aws_subnet.database_layer_subnets[count.index].id
  route_table_id = aws_route_table.database_layer_route_table.id
}