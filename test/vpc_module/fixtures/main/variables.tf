variable "name" { default = "my-vpc" }
variable "region" { default = "us-east-1" }
variable "vpc_cidr" { default = "10.1.0.0/16" }
variable "create_rds_subnets" { default = false }
variable "create_internet_gateway" { default = false }
variable "create_nat_gateway" { default = false }
variable "create_vpc_flow_logs" { default = false }
variable "vpc_endpoints" { default = [] }
variable "tags" { default = {} }
variable "test_resource_tag" { default = "" }
variable "public_subnet_count" { default = 3 }
variable "private_subnet_count" { default = 3 }
variable "rds_subnet_count" { default = 3 }
variable "mock_azs" {
  type    = list(string)
  default = []
}
variable "custom_subnets" {
  type = list(object({
    name         = string
    public       = bool
    subnet_count = number
  }))
  default = []
}
variable "additional_custom_subnets" {
  description = "Map of additional custom subnets to create"
  type = map(object({
    type       = string
    cidr_block = string
  }))
  default = {}
}
