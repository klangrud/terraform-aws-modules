# test/vpc_module/fixtures/custom-subnet-test/main.tf
variable "region" {
  type        = string
  description = "Region of vpc"
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
variable "test_resource_tag" {
  type        = string
  description = "Tag to mark resources created by automated tests for cleanup."
}

variable "custom_subnets" {
  type = list(object({
    name         = string
    public       = bool
    subnet_count = number
  }))
  description = "Custom Subnets of vpc"
}

module "vpc" {
  source            = "../../../../modules/vpc_module"
  name              = "my-vpc"
  region            = var.region
  vpc_cidr          = var.vpc_cidr
  test_resource_tag = var.test_resource_tag
  custom_subnets    = var.custom_subnets
  mock_azs          = var.mock_azs
}
