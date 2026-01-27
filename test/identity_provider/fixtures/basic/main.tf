provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "identity_provider" {
  source = "../../../../modules/identity_provider"

  env                        = var.env
  saml_metadata_document     = var.saml_metadata_document
  provider_name              = var.provider_name
  create_role_discovery_user = var.create_role_discovery_user
  role_discovery_user_name   = var.role_discovery_user_name
  tags                       = var.tags
}
