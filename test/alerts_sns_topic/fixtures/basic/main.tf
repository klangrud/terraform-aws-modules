provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  default_tags {
    tags = {
      Environment = "test"
    }
  }
}

module "alerts_sns_topic" {
  source = "../../../../modules/alerts_sns_topic"

  sns_topic_name  = var.sns_topic_name
  email_recipient = var.email_recipient
}
