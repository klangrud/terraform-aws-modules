# test/vpc_module/fixtures/custom-subnet-test/main.tf
variable "create_rds_subnets" {
  type        = bool
  description = "Create RDS Subnets boolean"
}

variable "region" {
  type        = string
  description = "Region of vpc"
}
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for the test VPC"
}
variable "test_resource_tag" {
  type        = string
  description = "Tag to mark resources created by automated tests for cleanup."
}

module "vpc" {
  source             = "../../../../modules/vpc_module"
  name               = "my-vpc"
  region             = var.region
  vpc_cidr           = var.vpc_cidr
  test_resource_tag  = var.test_resource_tag
  create_rds_subnets = var.create_rds_subnets
}
