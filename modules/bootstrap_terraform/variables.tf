# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# You must provide a value for each of these parameters.
# ---------------------------------------------------------------------------------------------------------------------

variable "s3_bucket_name" {
  description = "The s3 bucket name to store terraform state."
  type        = string
}

variable "dynamodb_table_name" {
  description = "The dynamoDB table name to store terraform locks."
  type        = string
}

variable "short_env" {
  description = "Short environment. e.g. prod."
  type        = string
}

variable "tags" {
  description = "Tags to apply to these resources."
  type        = map(string)
}

variable "aws_account_id" {
  description = "AWS account id."
  type        = string
}

variable "infra_account_id" {
  description = "AWS Infrastructure account id."
  type        = string
  default     = "123456789012"
}

### AWS IAM terraform-service-role Policies
variable "aws_policy_arns_terraform_service_role" {
  description = "AWS Policy arns for Terraform Service Role"
  type        = list(string)
  default = [
    "arn:aws:iam::aws:policy/AdministratorAccess"
  ]
}

variable "max_session_timeout_terraform_service_role" {
  description = "AWS IAM Role Max Session Timeout for Terraform Service Role"
  type        = string
  default     = "3600"
}
