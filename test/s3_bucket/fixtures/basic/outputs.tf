output "bucket_arn" {
  description = "ARN of the S3 bucket"
  value       = module.s3_bucket.aws_s3_bucket_arn
}

output "bucket_id" {
  description = "ID of the S3 bucket"
  value       = module.s3_bucket.aws_s3_bucket_id
}

output "bucket_name" {
  description = "Name of the S3 bucket"
  value       = module.s3_bucket.aws_s3_bucket_name
}

output "bucket_region" {
  description = "Region of the S3 bucket"
  value       = module.s3_bucket.aws_s3_bucket_region
}
