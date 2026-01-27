provider "aws" {
  region                      = var.region
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "vpc" {
  source                    = "../../../../modules/vpc_module"
  name                      = var.name
  region                    = var.region
  vpc_cidr                  = var.vpc_cidr
  test_resource_tag         = var.test_resource_tag
  create_nat_gateway        = var.create_nat_gateway
  create_internet_gateway   = var.create_internet_gateway
  create_rds_subnets        = var.create_rds_subnets
  vpc_endpoints             = var.vpc_endpoints
  tags                      = var.tags
  mock_azs                  = var.mock_azs
  public_subnet_count       = var.public_subnet_count
  private_subnet_count      = var.private_subnet_count
  rds_subnet_count          = var.rds_subnet_count
  custom_subnets            = var.custom_subnets
  additional_custom_subnets = var.additional_custom_subnets
}
