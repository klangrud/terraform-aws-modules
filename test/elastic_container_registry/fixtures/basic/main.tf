provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "elastic_container_registry" {
  source = "../../../../modules/elastic_container_registry"

  aws_ecr_repository_name = var.aws_ecr_repository_name
}
