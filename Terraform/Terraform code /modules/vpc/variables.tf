//============= All the variables will be populated by the calling function values =============//

variable "region" {
  description = "AWS region to deploy the resources in"
}

variable "vpc_conf" {
  description = "Network resources related configuration for the creation of VPC, Subnets, Internet Gateway, NAT gateway, Route table etc" 
}

variable "environment" {
  description = "Environment tag to be used. Ex: dev/qa/production"
}