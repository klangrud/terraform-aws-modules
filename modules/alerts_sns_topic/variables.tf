variable "sns_topic_name" {
  type        = string
  description = "Name of the alert sns topic"
}

variable "email_recipient" {
  type        = string
  description = "Email to receive alerts"
}
