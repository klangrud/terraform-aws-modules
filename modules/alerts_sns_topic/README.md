# Alerts SNS Topic Module

A Terraform module for creating SNS topics with email subscriptions for alert notifications.

## Features

- KMS encryption using AWS managed keys
- Email subscription with automatic confirmation
- IAM policy for CloudWatch and other AWS services to publish

## Usage

### Basic Alert Topic

```hcl
module "alerts" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/alerts_sns_topic?ref=main"

  sns_topic_name  = "production-alerts"
  email_recipient = "devops-team@example.com"
}
```

### Application-Specific Alerts

```hcl
module "app_alerts" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/alerts_sns_topic?ref=main"

  sns_topic_name  = "my-app-alerts"
  email_recipient = "app-team@example.com"
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
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.27.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_sns_topic.sns-topic](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic) | resource |
| [aws_sns_topic_policy.sns-topic-policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_policy) | resource |
| [aws_sns_topic_subscription.sns-topic-subscription](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/sns_topic_subscription) | resource |
| [aws_iam_policy_document.iam-policy-document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_kms_key.sns](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/kms_key) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_email_recipient"></a> [email\_recipient](#input\_email\_recipient) | Email to receive alerts | `string` | n/a | yes |
| <a name="input_sns_topic_name"></a> [sns\_topic\_name](#input\_sns\_topic\_name) | Name of the alert sns topic | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_sns_topic_arn"></a> [aws\_sns\_topic\_arn](#output\_aws\_sns\_topic\_arn) | n/a |
<!-- END_TF_DOCS -->
