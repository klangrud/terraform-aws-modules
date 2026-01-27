# ECS Monitoring

Provides comprehensive CloudWatch monitoring and alerting for ECS Fargate services, including CPU utilization, memory usage, and task restart tracking with configurable SNS notifications.

## Features

- CPU utilization monitoring with configurable thresholds and evaluation periods
- Memory utilization monitoring for ECS services
- Task restart count tracking to detect service instability
- Automated SNS topic creation for centralized alerting
- Support for multiple notification endpoints (email, SMS, Lambda, etc.)
- Configurable metric periods and alarm thresholds

## Usage

### Basic ECS Service Monitoring with Email Alerts

```hcl
module "api_service_monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"

  ecs_cluster_name = "production-cluster"
  ecs_service_name = "api-service"

  sns_topic_name = "api-service-alerts"
  sns_subscriptions = [
    {
      protocol = "email"
      endpoint = "team@example.com"
    }
  ]
}
```

### Custom Thresholds for High-Performance Services

```hcl
module "backend_api_monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"

  ecs_cluster_name = "production-cluster"
  ecs_service_name = "backend-api"

  # Higher thresholds for resource-intensive workloads
  cpu_threshold    = 90
  memory_threshold = 85

  # Faster detection with shorter evaluation periods
  cpu_evaluation_periods    = 1
  memory_evaluation_periods = 1
  error_evaluation_periods  = 1

  # More frequent metric collection (every 1 minute)
  metric_period = 60

  sns_topic_name = "backend-api-critical-alerts"
  sns_subscriptions = [
    {
      protocol = "email"
      endpoint = "oncall@example.com"
    },
    {
      protocol = "sms"
      endpoint = "+15551234567"
    }
  ]
}
```

### Multi-Endpoint Alerting Configuration

```hcl
module "data_pipeline_monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"

  ecs_cluster_name = "production-cluster"
  ecs_service_name = "report-generator"

  cpu_threshold    = 75
  memory_threshold = 80
  error_threshold  = 3

  sns_topic_name = "data-pipeline-alerts"
  sns_subscriptions = [
    {
      protocol = "email"
      endpoint = "team@example.com"
    },
    {
      protocol = "email"
      endpoint = "devops@example.com"
    },
    {
      protocol = "lambda"
      endpoint = "arn:aws:lambda:us-east-2:123456789012:function:pagerduty-integration"
    }
  ]
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_metric_alarm.cpu_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.memory_high](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_cloudwatch_metric_alarm.task_errors](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_metric_alarm) | resource |
| [aws_sns_topic.monitoring_alerts](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_subscription.monitoring_alerts_subscriptions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cpu_evaluation_periods"></a> [cpu\_evaluation\_periods](#input\_cpu\_evaluation\_periods) | Number of evaluation periods for CPU alarm | `number` | `2` | no |
| <a name="input_cpu_threshold"></a> [cpu\_threshold](#input\_cpu\_threshold) | CPU utilization threshold for the alarm | `number` | `80` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | Name of the ECS Cluster | `string` | n/a | yes |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | Name of the ECS Service | `string` | n/a | yes |
| <a name="input_error_evaluation_periods"></a> [error\_evaluation\_periods](#input\_error\_evaluation\_periods) | Number of evaluation periods for error alarm | `number` | `2` | no |
| <a name="input_error_threshold"></a> [error\_threshold](#input\_error\_threshold) | Task error count threshold for alarm | `number` | `5` | no |
| <a name="input_memory_evaluation_periods"></a> [memory\_evaluation\_periods](#input\_memory\_evaluation\_periods) | Number of evaluation periods for memory alarm | `number` | `2` | no |
| <a name="input_memory_threshold"></a> [memory\_threshold](#input\_memory\_threshold) | Memory utilization threshold for the alarm | `number` | `80` | no |
| <a name="input_metric_period"></a> [metric\_period](#input\_metric\_period) | Period in seconds for CloudWatch metrics | `number` | `300` | no |
| <a name="input_sns_subscriptions"></a> [sns\_subscriptions](#input\_sns\_subscriptions) | List of subscriptions for the SNS topic | <pre>list(object({<br>    protocol = string<br>    endpoint = string<br>  }))</pre> | `[]` | no |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the SNS topic for notifications | `string` | `"ecs_monitoring-alerts"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_cpu_alarm_arn"></a> [cpu\_alarm\_arn](#output\_cpu\_alarm\_arn) | The ARN of the CPU CloudWatch Alarm |
| <a name="output_memory_alarm_arn"></a> [memory\_alarm\_arn](#output\_memory\_alarm\_arn) | The ARN of the Memory CloudWatch Alarm |
| <a name="output_sns_topic_arn"></a> [sns\_topic\_arn](#output\_sns\_topic\_arn) | The ARN of the SNS topic used for notifications |
| <a name="output_task_errors_alarm_arn"></a> [task\_errors\_alarm\_arn](#output\_task\_errors\_alarm\_arn) | The ARN of the Task Errors CloudWatch Alarm |
<!-- END_TF_DOCS -->
