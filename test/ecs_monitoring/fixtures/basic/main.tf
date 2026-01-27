provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "ecs_monitoring" {
  source = "../../../../modules/ecs_monitoring"

  ecs_cluster_name          = var.ecs_cluster_name
  ecs_service_name          = var.ecs_service_name
  cpu_threshold             = var.cpu_threshold
  cpu_evaluation_periods    = var.cpu_evaluation_periods
  memory_threshold          = var.memory_threshold
  memory_evaluation_periods = var.memory_evaluation_periods
  error_threshold           = var.error_threshold
  error_evaluation_periods  = var.error_evaluation_periods
  metric_period             = var.metric_period
  sns_topic_name            = var.sns_topic_name
  sns_subscriptions         = var.sns_subscriptions
}
