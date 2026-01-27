# Monitoring & Alerting Modules

Modules for CloudWatch monitoring, alarms, and notification management.

## Table of Contents

- [ecs_monitoring](#ecs_monitoring)
- [alerts_sns_topic](#alerts_sns_topic)

---

## ecs_monitoring

### Overview

Comprehensive CloudWatch monitoring for ECS services with automated alerting on CPU, memory, and task failures.

### Key Features

- **CPU Monitoring**: Alert on high CPU utilization
- **Memory Monitoring**: Alert on high memory utilization
- **Task Failure Detection**: Alert on task restart/failure patterns
- **SNS Integration**: Email notifications for all alarms
- **Configurable Thresholds**: Customize alarm thresholds and evaluation periods

### Alarms Created

1. **CPU Utilization Alarm**
   - Metric: CPUUtilization
   - Default Threshold: 80%
   - Evaluation Periods: 2 consecutive periods

2. **Memory Utilization Alarm**
   - Metric: MemoryUtilization
   - Default Threshold: 80%
   - Evaluation Periods: 2 consecutive periods

3. **Task Restart/Error Alarm**
   - Metric: Service task count drops
   - Default Threshold: 5 restarts
   - Evaluation Periods: 1 period

### Architecture

```
┌────────────────────────────────────────┐
│ ECS Service                            │
│                                        │
│ ┌────────────┐  ┌────────────┐        │
│ │ Task 1     │  │ Task 2     │        │
│ │ CPU: 75%   │  │ CPU: 82%   │        │
│ │ Memory:65% │  │ Memory:78% │        │
│ └────────────┘  └────────────┘        │
└──────────┬─────────────────────────────┘
           │ CloudWatch Metrics
           ▼
┌────────────────────────────────────────┐
│ CloudWatch Alarms                      │
│                                        │
│ • CPU > 80% for 2 periods    [ALARM]  │
│ • Memory > 80% for 2 periods [OK]     │
│ • Task restarts > 5          [OK]     │
└──────────┬─────────────────────────────┘
           │ Alarm State: ALARM
           ▼
┌────────────────────────────────────────┐
│ SNS Topic                              │
│                                        │
│ Subscriptions:                         │
│ • ops-team@example.com                 │
│ • slack-webhook                        │
│ • pagerduty-integration                │
└────────────────────────────────────────┘
```

### Usage Example

#### Basic ECS Monitoring

```hcl
module "app_monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"

  ecs_cluster_name = "production-cluster"
  ecs_service_name = "web-api"
  sns_topic_name   = "ecs-alerts-prod"

  sns_subscriptions = [
    {
      protocol = "email"
      endpoint = "ops-team@example.com"
    }
  ]

  tags = {
    Environment = "production"
    Application = "web-api"
  }
}
```

#### Custom Thresholds

```hcl
module "high_utilization_monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"

  ecs_cluster_name = "production-cluster"
  ecs_service_name = "ml-processor"
  sns_topic_name   = "ml-alerts"

  # Higher thresholds for ML workload
  cpu_threshold    = 90
  memory_threshold = 85

  # More sensitive to errors
  error_threshold = 3

  # Longer evaluation periods
  cpu_evaluation_periods    = 3
  memory_evaluation_periods = 3
  metric_period            = 600  # 10 minutes

  sns_subscriptions = [
    {
      protocol = "email"
      endpoint = "ml-team@example.com"
    },
    {
      protocol = "https"
      endpoint = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
    }
  ]

  tags = {
    Environment = "production"
    Workload    = "ml-processing"
  }
}
```

#### Multiple Notification Channels

```hcl
module "critical_service_monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"

  ecs_cluster_name = "production-cluster"
  ecs_service_name = "payment-processor"
  sns_topic_name   = "critical-alerts"

  sns_subscriptions = [
    # Email notifications
    {
      protocol = "email"
      endpoint = "oncall@example.com"
    },
    {
      protocol = "email"
      endpoint = "cto@example.com"
    },
    # PagerDuty integration
    {
      protocol = "https"
      endpoint = "https://events.pagerduty.com/integration/xxx/enqueue"
    },
    # Slack webhook
    {
      protocol = "https"
      endpoint = "https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXX"
    }
  ]

  tags = {
    Environment = "production"
    Criticality = "high"
    Application = "payment-processor"
  }
}
```

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `ecs_cluster_name` | string | ECS cluster name to monitor |
| `ecs_service_name` | string | ECS service name to monitor |
| `sns_topic_name` | string | SNS topic name for alerts |
| `sns_subscriptions` | list(object) | List of SNS subscriptions |
| `tags` | map(string) | Resource tags |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `cpu_threshold` | number | 80 | CPU utilization threshold (%) |
| `memory_threshold` | number | 80 | Memory utilization threshold (%) |
| `error_threshold` | number | 5 | Task restart count threshold |
| `cpu_evaluation_periods` | number | 2 | CPU alarm evaluation periods |
| `memory_evaluation_periods` | number | 2 | Memory alarm evaluation periods |
| `metric_period` | number | 300 | Metric collection period (seconds) |

### Outputs

| Output | Description |
|--------|-------------|
| `sns_topic_arn` | SNS topic ARN |
| `cpu_alarm_arn` | CPU alarm ARN |
| `memory_alarm_arn` | Memory alarm ARN |
| `task_errors_alarm_arn` | Task errors alarm ARN |

### SNS Subscription Formats

```hcl
# Email
{
  protocol = "email"
  endpoint = "user@example.com"
}

# SMS
{
  protocol = "sms"
  endpoint = "+1234567890"
}

# HTTPS Webhook
{
  protocol = "https"
  endpoint = "https://hooks.example.com/webhook"
}

# Lambda Function
{
  protocol = "lambda"
  endpoint = "arn:aws:lambda:us-east-2:123456789012:function:alert-handler"
}

# SQS Queue
{
  protocol = "sqs"
  endpoint = "arn:aws:sqs:us-east-2:123456789012:alert-queue"
}
```

### Best Practices

1. **Threshold Tuning**: Monitor for 2 weeks, adjust thresholds based on baseline
2. **Alert Fatigue**: Avoid setting thresholds too low (causes alert fatigue)
3. **Multiple Channels**: Use email + chat + pagerduty for critical services
4. **Runbooks**: Document response procedures for each alarm
5. **Test Alerts**: Manually trigger alarms to verify notification delivery

### Troubleshooting

#### Issue: Not receiving email notifications

**Solutions**:
1. Check email subscription confirmation in inbox
2. Verify SNS topic subscriptions: `aws sns list-subscriptions-by-topic --topic-arn <arn>`
3. Check spam/junk folders

#### Issue: False positive alarms

**Solutions**:
1. Increase evaluation periods
2. Raise threshold values
3. Increase metric period for more stable metrics

#### Issue: Missing task failure alerts

**Solutions**:
1. Verify ECS service has correct `desiredCount`
2. Check CloudWatch metrics are being published
3. Review alarm configuration

---

## alerts_sns_topic

### Overview

Creates an SNS topic for general alerting and notifications with email subscriptions.

### Usage Example

```hcl
module "alerts" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/alerts_sns_topic?ref=main"

  sns_topic_name  = "infrastructure-alerts"
  email_recipient = "infrastructure@example.com"

  tags = {
    Purpose = "infrastructure-monitoring"
  }
}
```

### Features

- KMS encryption for message security
- EventBridge publish permissions
- Email subscription

### Outputs

- `sns_topic_arn`: Topic ARN for alarm configuration

### Use Cases

- CloudWatch alarm notifications
- EventBridge rule targets
- Lambda function notifications
- Custom application alerts

---

## Monitoring Best Practices

### Alarm Naming Convention

Use descriptive names: `{service}-{metric}-{environment}`

Example: `web-api-high-cpu-prod`

### Alert Severity Levels

**Critical**: Immediate attention required
- Service down
- Data loss risk
- Security breach

**Warning**: Investigate soon
- High resource utilization
- Elevated error rates
- Performance degradation

**Info**: Awareness only
- Deployment notifications
- Scheduled maintenance
- Configuration changes

### Response Procedures

1. **Acknowledge**: Confirm receipt of alert
2. **Investigate**: Check logs, metrics, recent changes
3. **Mitigate**: Take corrective action
4. **Document**: Record findings and resolution
5. **Follow-up**: Review and prevent recurrence

### Dashboard Integration

Create CloudWatch dashboards for visual monitoring:

```hcl
resource "aws_cloudwatch_dashboard" "ecs_overview" {
  dashboard_name = "ECS-Production-Overview"

  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", {
              stat = "Average"
              dimensions = {
                ServiceName = "web-api"
                ClusterName = "production-cluster"
              }
            }]
          ]
          period = 300
          stat   = "Average"
          region = "us-east-2"
          title  = "ECS CPU Utilization"
        }
      }
    ]
  })
}
```
