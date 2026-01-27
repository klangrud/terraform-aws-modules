# test/vpc_module/fixtures/tag-test/main.tf
variable "name" {
  type        = string
  description = "Name of vpc"
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

variable "mock_azs" {
  description = "Optional mock AZs for testing."
  type        = list(string)
  default     = []
}

module "vpc" {
  source            = "../../../../modules/vpc_module"
  name              = var.name
  region            = var.region
  vpc_cidr          = var.vpc_cidr
  test_resource_tag = var.test_resource_tag
  mock_azs          = var.mock_azs
}
