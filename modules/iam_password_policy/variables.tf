# ---------------------------------------------------------------------------------------------------------------------
# PASSWORD POLICY CONFIGURATION
# All settings have secure defaults but can be customized
# ---------------------------------------------------------------------------------------------------------------------

variable "minimum_password_length" {
  description = "Minimum length for IAM user passwords. AWS minimum is 6, recommended is 14+."
  type        = number
  default     = 14
}

variable "require_lowercase_characters" {
  description = "Require at least one lowercase letter."
  type        = bool
  default     = true
}

variable "require_uppercase_characters" {
  description = "Require at least one uppercase letter."
  type        = bool
  default     = true
}

variable "require_numbers" {
  description = "Require at least one number."
  type        = bool
  default     = true
}

variable "require_symbols" {
  description = "Require at least one special character."
  type        = bool
  default     = true
}

variable "allow_users_to_change_password" {
  description = "Allow IAM users to change their own passwords."
  type        = bool
  default     = true
}

variable "max_password_age" {
  description = "Maximum age (in days) before password expires. Set to 0 to disable expiration."
  type        = number
  default     = 90
}

variable "password_reuse_prevention" {
  description = "Number of previous passwords that cannot be reused. Set to 0 to disable."
  type        = number
  default     = 24
}

variable "hard_expiry" {
  description = "Prevent users from resetting expired passwords without admin help."
  type        = bool
  default     = false
}
