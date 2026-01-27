variable "ecs_cluster_name" {
  description = "Name of the ECS cluster"
  type        = string
  default     = "test-cluster"
}

variable "ecs_service_name" {
  description = "Name of the ECS service"
  type        = string
  default     = "test-service"
}

variable "cpu_threshold" {
  description = "CPU utilization threshold"
  type        = number
  default     = 80
}

variable "cpu_evaluation_periods" {
  description = "CPU evaluation periods"
  type        = number
  default     = 2
}

variable "memory_threshold" {
  description = "Memory utilization threshold"
  type        = number
  default     = 80
}

variable "memory_evaluation_periods" {
  description = "Memory evaluation periods"
  type        = number
  default     = 2
}

variable "error_threshold" {
  description = "Error count threshold"
  type        = number
  default     = 5
}

variable "error_evaluation_periods" {
  description = "Error evaluation periods"
  type        = number
  default     = 2
}

variable "metric_period" {
  description = "Metric period in seconds"
  type        = number
  default     = 300
}

variable "sns_topic_name" {
  description = "SNS topic name"
  type        = string
  default     = "test-ecs-monitoring-alerts"
}

variable "sns_subscriptions" {
  description = "SNS subscriptions"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}
