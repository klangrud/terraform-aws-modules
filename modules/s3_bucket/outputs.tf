output "aws_s3_bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.arn
}

output "aws_s3_bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.id
}

output "aws_s3_bucket_name" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.bucket
}

output "aws_s3_bucket_versioning" {
  description = "The versioning configuration of the S3 bucket"
  value       = aws_s3_bucket.s3_bucket.versioning
}

output "aws_s3_bucket_region" {
  description = "The AWS region where the S3 bucket is located"
  value       = data.aws_region.current.id
}
