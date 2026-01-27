provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "transfer_family_sftp_secret" {
  source = "../../../../modules/transfer_family_sftp_secret"

  secret_name         = var.secret_name
  role_arn            = var.role_arn
  home_directory      = var.home_directory
  accepted_ip_network = var.accepted_ip_network
  password_rotation   = var.password_rotation
  password_length     = var.password_length
  description         = var.description
  tags                = var.tags
}
