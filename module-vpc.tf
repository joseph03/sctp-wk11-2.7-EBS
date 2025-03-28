#used by vpc
 data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
 source  = "terraform-aws-modules/vpc/aws"

 name = "${local.name_prefix}-2.7vpc"
 cidr = "10.0.0.0/16"

 #azs             = ["us-east-1a", "us-east-1b", "us-east-1c"]   #replaced this with data blocks
 # use of data for azs assignment
 azs             = slice(data.aws_availability_zones.available.names, 0, 3)  #max 3 az
 private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
 public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

// to enable NAT gateway
 enable_nat_gateway   = true   # enable NAT gateway
 single_nat_gateway   = true   # use a single NAT gateway

 enable_dns_hostnames = true

 tags = {
  Terraform = "true"
 }
}

output "nat_gateway_ids" {
 value = module.vpc.natgw_ids
}

#jt: add the below
output "private_subnet_ids" {
  value = module.vpc.private_subnets
  description = "List of private subnet IDs"
}

# output az names. This will display first as the display is based on 
# the sequence of execution after terraform apply
output "az_names" {
  value       = module.vpc.azs
  description = "The AZs being used in this deployment"
}

