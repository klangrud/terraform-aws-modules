############################################
# S3 Bucket Outputs
############################################

output "s3_bucket_name" {
  description = "Name of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.id
}

output "s3_bucket_arn" {
  description = "ARN of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.arn
}

output "s3_bucket_region" {
  description = "Region of the S3 bucket for Terraform state"
  value       = aws_s3_bucket.terraform_state.region
}

############################################
# DynamoDB Table Outputs
############################################

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.id
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table for state locking"
  value       = aws_dynamodb_table.terraform_locks.arn
}

############################################
# IAM Role Outputs
############################################

output "terraform_service_role_arn" {
  description = "ARN of the Terraform service role"
  value       = aws_iam_role.terraform-service-role.arn
}

output "terraform_service_role_name" {
  description = "Name of the Terraform service role"
  value       = aws_iam_role.terraform-service-role.name
}

############################################
# Backend Configuration Helper
############################################

output "backend_config" {
  description = "Backend configuration block for use in other Terraform projects"
  value = {
    bucket         = aws_s3_bucket.terraform_state.id
    dynamodb_table = aws_dynamodb_table.terraform_locks.id
    encrypt        = true
  }
}
