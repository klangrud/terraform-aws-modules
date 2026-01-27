output "sns_topic_arn" {
  description = "The ARN of the SNS topic used for notifications"
  value       = aws_sns_topic.monitoring_alerts.arn
}

output "cpu_alarm_arn" {
  description = "The ARN of the CPU CloudWatch Alarm"
  value       = aws_cloudwatch_metric_alarm.cpu_high.arn
}

output "memory_alarm_arn" {
  description = "The ARN of the Memory CloudWatch Alarm"
  value       = aws_cloudwatch_metric_alarm.memory_high.arn
}

output "task_errors_alarm_arn" {
  description = "The ARN of the Task Errors CloudWatch Alarm"
  value       = aws_cloudwatch_metric_alarm.task_errors.arn
}
