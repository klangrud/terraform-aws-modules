output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = module.bootstrap.s3_bucket_name
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = module.bootstrap.s3_bucket_arn
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = module.bootstrap.dynamodb_table_name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = module.bootstrap.dynamodb_table_arn
}

output "terraform_service_role_arn" {
  description = "ARN of the Terraform service role"
  value       = module.bootstrap.terraform_service_role_arn
}

output "terraform_service_role_name" {
  description = "Name of the Terraform service role"
  value       = module.bootstrap.terraform_service_role_name
}

output "backend_config" {
  description = "Backend configuration block"
  value       = module.bootstrap.backend_config
}
