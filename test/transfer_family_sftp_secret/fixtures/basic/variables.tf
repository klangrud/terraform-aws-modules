variable "secret_name" {
  description = "Name for the Secrets Manager secret"
  type        = string
  default     = "s-test123/test-user"
}

variable "role_arn" {
  description = "ARN of the IAM role for SFTP user"
  type        = string
  default     = "arn:aws:iam::123456789012:role/test-sftp-role"
}

variable "home_directory" {
  description = "Home directory for the SFTP user"
  type        = string
  default     = "/test-bucket/uploads"
}

variable "accepted_ip_network" {
  description = "CIDR block of allowed source IPs"
  type        = string
  default     = "0.0.0.0/0"
}

variable "password_rotation" {
  description = "Value to trigger password rotation"
  type        = string
  default     = "initial"
}

variable "password_length" {
  description = "Length of the generated password"
  type        = number
  default     = 16
}

variable "description" {
  description = "Description for the secret"
  type        = string
  default     = "SFTP user credentials for AWS Transfer Family"
}

variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
