provider "aws" {
  alias                       = "test"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "s3_bucket" {
  source = "../../../../modules/s3_bucket"

  providers = {
    aws.provider = aws.test
  }

  bucket               = var.bucket
  force_destroy        = var.force_destroy
  tags                 = var.tags
  versioning           = var.versioning
  bucket_policies_json = var.bucket_policies_json
  bucket_folders       = var.bucket_folders
  enable_logging       = var.enable_logging
  logging_bucket       = var.logging_bucket
}
