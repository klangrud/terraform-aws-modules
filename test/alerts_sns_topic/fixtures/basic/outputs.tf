output "sns_topic_arn" {
  description = "ARN of the SNS topic"
  value       = module.alerts_sns_topic.aws_sns_topic_arn
}
