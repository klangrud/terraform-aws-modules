resource "aws_s3_object" "bucket_folders" {
  for_each = toset(var.bucket_folders)
  bucket   = aws_s3_bucket.s3_bucket.bucket
  key      = each.key
}
