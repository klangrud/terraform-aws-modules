# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "secret_name" {
  description = "Name for the Secrets Manager secret. Recommend format: {transfer-server-id}/{username}"
  type        = string
}

variable "role_arn" {
  description = "ARN of the IAM role that grants SFTP user access to S3"
  type        = string
}

variable "home_directory" {
  description = "Home directory path for the SFTP user (e.g., /bucket-name/folder)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "accepted_ip_network" {
  description = "CIDR block of allowed source IPs. Use 0.0.0.0/0 to allow all IPs."
  type        = string
  default     = "0.0.0.0/0"
}

variable "password_rotation" {
  description = "Change this value to trigger password rotation (e.g., use a date like 2024-01-15)"
  type        = string
  default     = "initial"
}

variable "password_length" {
  description = "Length of the generated password"
  type        = number
  default     = 16
}

variable "description" {
  description = "Description for the Secrets Manager secret"
  type        = string
  default     = "SFTP user credentials for AWS Transfer Family"
}

variable "tags" {
  description = "Tags to apply to the secret"
  type        = map(string)
  default     = {}
}
