resource "aws_s3_bucket" "s3_bucket" {
  provider      = aws.provider
  bucket        = var.bucket
  tags          = var.tags
  force_destroy = var.force_destroy
}

resource "aws_s3_bucket_server_side_encryption_configuration" "s3_bucket" {
  provider = aws.provider
  bucket   = aws_s3_bucket.s3_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
