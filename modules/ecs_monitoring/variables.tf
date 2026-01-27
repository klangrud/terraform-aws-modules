variable "ecs_cluster_name" {
  description = "Name of the ECS Cluster"
  type        = string
}

variable "ecs_service_name" {
  description = "Name of the ECS Service"
  type        = string
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for the alarm"
  type        = number
  default     = 80
}

variable "cpu_evaluation_periods" {
  description = "Number of evaluation periods for CPU alarm"
  type        = number
  default     = 2
}

variable "memory_threshold" {
  description = "Memory utilization threshold for the alarm"
  type        = number
  default     = 80
}

variable "memory_evaluation_periods" {
  description = "Number of evaluation periods for memory alarm"
  type        = number
  default     = 2
}

variable "error_threshold" {
  description = "Task error count threshold for alarm"
  type        = number
  default     = 5
}

variable "error_evaluation_periods" {
  description = "Number of evaluation periods for error alarm"
  type        = number
  default     = 2
}

variable "metric_period" {
  description = "Period in seconds for CloudWatch metrics"
  type        = number
  default     = 300
}

variable "sns_topic_name" {
  description = "Name of the SNS topic for notifications"
  type        = string
  default     = "ecs_monitoring-alerts"
}

variable "sns_subscriptions" {
  description = "List of subscriptions for the SNS topic"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}
