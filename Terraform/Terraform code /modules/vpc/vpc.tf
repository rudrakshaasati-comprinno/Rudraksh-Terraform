data "aws_availability_zones" "available" {
  state = "available"
}

//=======================================================================================================\\
//                                           Resource for VPC                                            \\
//=======================================================================================================\\
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc_conf.vpc.cidr_vpc
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = merge(
              {
              "Name" = "${var.environment}-vpc"
              "Environment" = var.environment
              },
              var.vpc_conf.vpc.additional_tags
          )
}

//=======================================================================================================\\
//                                        Creation of Public Subnets                                     \\
//=======================================================================================================\\
resource "aws_subnet" "public_subnets" { 
    count = length( var.vpc_conf.subnets.public_subnets.cidr )
    vpc_id = aws_vpc.vpc.id
    map_public_ip_on_launch = true
    cidr_block = element(var.vpc_conf.subnets.public_subnets.cidr, count.index)
    availability_zone = data.aws_availability_zones.available.names[count.index]
    tags = merge (
    {
      Name = "${var.environment}-${var.vpc_conf.subnets.public_subnets.name}-${count.index}"
      Environment = var.environment
    },
    var.vpc_conf.subnets.public_subnets.additional_tags
  )
}

//=======================================================================================================
//                            Creation of Public route table having route to IGW 
//=======================================================================================================
resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name" = "${var.environment}-public-route-table"
      "Environment" = var.environment
    },
  )
}

//=======================================================================================================\\
//                                              PUBLIC ROUTE                                             \\
//=======================================================================================================\\

resource "aws_route" "public_route" {
  route_table_id = aws_route_table.rtb_public.id
  destination_cidr_block = "0.0.0.0/0"
  
  gateway_id = aws_internet_gateway.igw.id
}

//=======================================================================================================\\
//                                   ASSOCIATE PUBLIC SUBNETS TO ROUTE TABLE                             \\ 
//=======================================================================================================\\

resource "aws_route_table_association" "public_route_association" {
  count = length( var.vpc_conf.subnets.public_subnets.cidr )
  subnet_id = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.rtb_public.id
}

//=======================================================================================================\\
//                           Internet Gateway is used to enable connection to internet                   \\
//=======================================================================================================\\

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    "Name" = "${var.environment}-IGW"
    "Environment" = var.environment
  }
}

//=======================================================================================================\\
//                                   Creation of Elastic IPs for individual NAT                          \\
//=======================================================================================================\\
resource "aws_eip" "natA" {
  domain = "vpc"
}

//=======================================================================================================\\
//                                       Creation of NAT gateways                                        \\
//=======================================================================================================\\
resource "aws_nat_gateway" "ngwA" {
  depends_on = [aws_internet_gateway.igw]
  allocation_id =  aws_eip.natA.id
  subnet_id = aws_subnet.public_subnets[0].id
  tags = merge(
            {
              "Name" = "${var.environment}-NAT-GW"
              "Environment" = var.environment
            },
            var.vpc_conf.nat_gateway.additional_tags
        )
}

//=======================================================================================================\\
//                                   Creation of Private Application Subnets                             \\
//=======================================================================================================\\

resource "aws_subnet" "private_app_subnets" { 
  count = length( var.vpc_conf.subnets.private_app_subnets.cidr )
  vpc_id = aws_vpc.vpc.id 
  cidr_block = element(var.vpc_conf.subnets.private_app_subnets.cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge (
    {
      Name = "${var.environment}-${var.vpc_conf.subnets.private_app_subnets.name}-${count.index}"
      Environment = var.environment
    },
    var.vpc_conf.subnets.private_app_subnets.additional_tags
  )
}

//=======================================================================================================\\
//                        Creation of Private route table having route to Nat-Gateway                    \\
//=======================================================================================================\\
resource "aws_route_table" "rtb_private_app" {
  vpc_id = aws_vpc.vpc.id
  tags = merge(
    {
      "Name" = "${var.environment}-private-app-route-table"
      "Environment" = var.environment
    },
  )
}

//=======================================================================================================\\
//                                        PRIVATE ROUTE                                                  \\
//=======================================================================================================\\
resource "aws_route" "private_route" {
  route_table_id = aws_route_table.rtb_private_app.id
  destination_cidr_block = "0.0.0.0/0" 
  nat_gateway_id = aws_nat_gateway.ngwA.id
}

//=======================================================================================================\\
//                         ASSOCIATE PRIVATE APP SUBNETS TO PRIVATE ROUTE TABLE                          \\
//=======================================================================================================\\
resource "aws_route_table_association" "private_control_plane_route_association"{
  count = length(var.vpc_conf.subnets.private_app_subnets.cidr)
  subnet_id = aws_subnet.private_app_subnets[count.index].id
  route_table_id = aws_route_table.rtb_private_app.id
}

//=======================================================================================================\\
//                                 Creation of private db Subnets                                        \\
//=======================================================================================================\\
resource "aws_subnet" "private_db_subnets" {  
  count = length( var.vpc_conf.subnets.private_db_subnets.cidr )
  vpc_id = aws_vpc.vpc.id
  cidr_block = element(var.vpc_conf.subnets.private_db_subnets.cidr, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  tags = merge (
    {
      Name = "${var.environment}-${var.vpc_conf.subnets.private_db_subnets.name}-${count.index}"
      Environment = var.environment
      
    },
    var.vpc_conf.subnets.private_db_subnets.additional_tags
  )
}

//=======================================================================================================\\
//                                 CREATION OF PRIVATE DB ROUTE TABLE                                    \\
//=======================================================================================================\\
resource "aws_route_table" "rtb_private_db" {
  vpc_id = aws_vpc.vpc.id
  tags = {
      Name = "${var.environment}-private-db-route-table"
      Environment = var.environment
    }
}
//=======================================================================================================\\
//                               ASSOCIATE PRIVATE DB SUBNETS TO ROUTE TABLE                             \\
//=======================================================================================================\\
resource "aws_route_table_association" "private_route_association_db"{
  count =  length( var.vpc_conf.subnets.private_db_subnets.cidr )
  subnet_id = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.rtb_private_db.id
}