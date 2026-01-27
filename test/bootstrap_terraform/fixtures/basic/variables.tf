variable "s3_bucket_name" {
  description = "The S3 bucket name to store terraform state"
  type        = string
  default     = "test-terraform-state-123456789012"
}

variable "dynamodb_table_name" {
  description = "The DynamoDB table name to store terraform locks"
  type        = string
  default     = "test-terraform-locks"
}

variable "short_env" {
  description = "Short environment name"
  type        = string
  default     = "test"
}

variable "aws_account_id" {
  description = "AWS account ID"
  type        = string
  default     = "123456789012"
}

variable "infra_account_id" {
  description = "Infrastructure account ID"
  type        = string
  default     = "123456789012"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "terraform"
    Purpose     = "unit-testing"
  }
}

variable "aws_policy_arns_terraform_service_role" {
  description = "AWS Policy ARNs for Terraform Service Role"
  type        = list(string)
  default     = ["arn:aws:iam::aws:policy/AdministratorAccess"]
}

variable "max_session_timeout_terraform_service_role" {
  description = "AWS IAM Role Max Session Timeout for Terraform Service Role"
  type        = string
  default     = "3600"
}
