resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "${var.ecs_service_name}-high-cpu"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.cpu_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = var.metric_period
  statistic           = "Average"
  threshold           = var.cpu_threshold
  alarm_description   = "High CPU utilization detected for ECS service ${var.ecs_service_name}"
  alarm_actions       = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "memory_high" {
  alarm_name          = "${var.ecs_service_name}-high-memory"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.memory_evaluation_periods
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = var.metric_period
  statistic           = "Average"
  threshold           = var.memory_threshold
  alarm_description   = "High memory usage detected for ECS service ${var.ecs_service_name}"
  alarm_actions       = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_cloudwatch_metric_alarm" "task_errors" {
  alarm_name          = "${var.ecs_service_name}-task-errors"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = var.error_evaluation_periods
  # metric_name         = "TaskCount"
  #metric_name         = "ServiceTaskFailureCount"
  metric_name = "TaskRestartCount"
  namespace   = "ECS/ContainerInsights"
  #namespace          = "AWS/ECS"
  period            = var.metric_period
  statistic         = "Sum"
  threshold         = var.error_threshold
  alarm_description = "ECS task errors detected for service ${var.ecs_service_name}"
  alarm_actions     = [aws_sns_topic.monitoring_alerts.arn]

  dimensions = {
    ClusterName = var.ecs_cluster_name
    ServiceName = var.ecs_service_name
  }
}

resource "aws_sns_topic" "monitoring_alerts" {
  name = var.sns_topic_name
}

resource "aws_sns_topic_subscription" "monitoring_alerts_subscriptions" {
  count     = length(var.sns_subscriptions)
  topic_arn = aws_sns_topic.monitoring_alerts.arn
  protocol  = var.sns_subscriptions[count.index]["protocol"]
  endpoint  = var.sns_subscriptions[count.index]["endpoint"]
}
