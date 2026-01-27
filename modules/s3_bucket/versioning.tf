resource "aws_s3_bucket_versioning" "s3_bucket" {
  provider = aws.provider
  bucket   = aws_s3_bucket.s3_bucket.id

  versioning_configuration {
    status = var.versioning
  }
}
