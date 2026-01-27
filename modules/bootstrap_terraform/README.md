# Bootstrap Terraform Module

A Terraform module for bootstrapping AWS accounts with Terraform state backend infrastructure (S3 bucket and DynamoDB table) and cross-account IAM role.

## Features

- S3 bucket for Terraform state storage
- DynamoDB table for state locking
- IAM role for cross-account Terraform deployments
- Secure by default (encryption, versioning)

## Usage

### Bootstrap New AWS Account

```hcl
module "bootstrap" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/bootstrap_terraform?ref=main"

  aws_account_id      = "123456789012"
  s3_bucket_name      = "mycompany-123456789012-terraform-state"
  dynamodb_table_name = "mycompany-123456789012-terraform-locking"
  short_env           = "prod"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### Bootstrap with Custom IAM Policies

```hcl
module "bootstrap_custom" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/bootstrap_terraform?ref=main"

  aws_account_id      = "123456789012"
  s3_bucket_name      = "mycompany-123456789012-terraform-state"
  dynamodb_table_name = "mycompany-123456789012-terraform-locking"
  short_env           = "dev"

  # Custom IAM policies for deployment role
  aws_policy_arns_terraform_service_role = [
    "arn:aws:iam::aws:policy/PowerUserAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess"
  ]

  tags = {
    Environment = "development"
  }
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
| [aws_dynamodb_table.terraform_locks](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/dynamodb_table) | resource |
| [aws_iam_role.terraform-service-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.terraform-service-role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.terraform_state](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_account_id"></a> [aws\_account\_id](#input\_aws\_account\_id) | AWS account id. | `string` | n/a | yes |
| <a name="input_aws_policy_arns_terraform_service_role"></a> [aws\_policy\_arns\_terraform\_service\_role](#input\_aws\_policy\_arns\_terraform\_service\_role) | AWS Policy arns for Terraform Service Role | `list(string)` | <pre>[<br>  "arn:aws:iam::aws:policy/AdministratorAccess"<br>]</pre> | no |
| <a name="input_dynamodb_table_name"></a> [dynamodb\_table\_name](#input\_dynamodb\_table\_name) | The dynamoDB table name to store terraform locks. | `string` | n/a | yes |
| <a name="input_infra_account_id"></a> [infra\_account\_id](#input\_infra\_account\_id) | AWS Infrastructure account id. | `string` | `"123456789012"` | no |
| <a name="input_max_session_timeout_terraform_service_role"></a> [max\_session\_timeout\_terraform\_service\_role](#input\_max\_session\_timeout\_terraform\_service\_role) | AWS IAM Role Max Session Timeout for Terraform Service Role | `string` | `"3600"` | no |
| <a name="input_s3_bucket_name"></a> [s3\_bucket\_name](#input\_s3\_bucket\_name) | The s3 bucket name to store terraform state. | `string` | n/a | yes |
| <a name="input_short_env"></a> [short\_env](#input\_short\_env) | Short environment. e.g. prod. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to these resources. | `map(string)` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
