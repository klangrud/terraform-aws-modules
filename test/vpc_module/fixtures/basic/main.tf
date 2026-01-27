# test/vpc_module/fixtures/basic/main.tf
variable "region" {
  type        = string
  description = "Region for the test VPC"
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the test VPC"
}

variable "mock_azs" {
  type        = list(string)
  default     = null
  description = "Mock AZs used for testing"
}

variable "vpc_endpoints" {
  type        = list(string)
  description = "List of endpoints for the test VPC"
  default     = []
}

variable "test_resource_tag" {
  type        = string
  description = "Tag to mark resources created by automated tests for cleanup."
}

module "vpc" {
  source                  = "../../../../modules/vpc_module"
  name                    = "test-basic-vpc"
  region                  = var.region
  vpc_cidr                = var.vpc_cidr
  test_resource_tag       = var.test_resource_tag
  create_nat_gateway      = true
  create_internet_gateway = true
  vpc_endpoints           = var.vpc_endpoints
  mock_azs                = var.mock_azs
}

output "vpc_id" {
  description = "The VPC ID created by the fixture root module."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_route_table_ids" {
  value = module.vpc.public_route_table_ids
}
output "private_route_table_ids" {
  value = module.vpc.private_route_table_ids
}
output "nat_gateway_id" {
  value = module.vpc.nat_gateway_id
}

output "internet_gateway_id" {
  value = module.vpc.internet_gateway_id
}
output "rds_subnet_ids" {
  value = module.vpc.rds_subnets
}

output "vpc_endpoints" {
  value = module.vpc.vpc_endpoints
}
