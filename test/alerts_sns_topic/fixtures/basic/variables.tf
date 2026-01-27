variable "sns_topic_name" {
  description = "Name of the SNS topic"
  type        = string
  default     = "test-alerts-topic"
}

variable "email_recipient" {
  description = "Email address to receive alerts"
  type        = string
  default     = "test@example.com"
}
