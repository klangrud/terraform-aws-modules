resource "aws_s3_bucket_notification" "bucket_notification" {
  provider    = aws.provider
  bucket      = aws_s3_bucket.s3_bucket.id
  eventbridge = true
}
