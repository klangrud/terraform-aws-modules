provider "aws" {
  region = "us-east-1"
  alias  = "source"
}

provider "aws" {
  region = "us-west-2"
  alias  = "destination"
}

module "s3_replication" {
  source = "../../../../modules/s3_bucket_replication"

  source_bucket_name      = var.source_bucket_name
  destination_bucket_name = var.destination_bucket_name
  source_account_id       = var.source_account_id
  destination_account_id  = var.destination_account_id

  source_bucket_exists      = var.source_bucket_exists
  destination_bucket_exists = var.destination_bucket_exists

  enable_bidirectional      = var.enable_bidirectional
  replication_rules         = var.replication_rules
  reverse_replication_rules = var.reverse_replication_rules

  source_replication_role_arn      = var.source_replication_role_arn
  destination_replication_role_arn = var.destination_replication_role_arn

  tags = var.tags

  providers = {
    aws.source      = aws.source
    aws.destination = aws.destination
  }
}
