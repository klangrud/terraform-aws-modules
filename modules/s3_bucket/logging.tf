locals {
  logging_bucket_name = var.logging_bucket != null ? var.logging_bucket : "logs-${data.aws_region.current.id}-${data.aws_caller_identity.current.account_id}"
}

data "aws_s3_bucket" "global_logging_bucket" {
  count    = var.enable_logging ? 1 : 0
  provider = aws.provider
  bucket   = local.logging_bucket_name
}

resource "aws_s3_bucket_logging" "s3_bucket_logging" {
  count    = var.enable_logging ? 1 : 0
  provider = aws.provider
  bucket   = aws_s3_bucket.s3_bucket.id

  target_bucket = data.aws_s3_bucket.global_logging_bucket[0].id
  target_prefix = "log/"
}
