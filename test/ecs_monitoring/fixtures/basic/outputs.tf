output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.ecs_monitoring.sns_topic_arn
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU alarm"
  value       = module.ecs_monitoring.cpu_alarm_arn
}

output "memory_alarm_arn" {
  description = "ARN of the memory alarm"
  value       = module.ecs_monitoring.memory_alarm_arn
}

output "task_errors_alarm_arn" {
  description = "ARN of the task errors alarm"
  value       = module.ecs_monitoring.task_errors_alarm_arn
}
