# ================================================================================
# EXISTING BUCKET DETECTION
# ================================================================================

# Detect existing source bucket (only if source_bucket_exists = true)
data "aws_s3_bucket" "source_existing" {
  count    = var.source_bucket_exists ? 1 : 0
  provider = aws.source
  bucket   = var.source_bucket_name
}

# Detect existing destination bucket (only if destination_bucket_exists = true)
data "aws_s3_bucket" "destination_existing" {
  count    = var.destination_bucket_exists ? 1 : 0
  provider = aws.destination
  bucket   = var.destination_bucket_name
}
