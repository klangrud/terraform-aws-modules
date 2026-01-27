# Elastic Container Registry (ECR)

Creates an AWS Elastic Container Registry repository with security best practices including immutable image tags and automatic vulnerability scanning on push.

## Features

- Immutable image tag configuration for production safety
- Automatic vulnerability scanning enabled on image push
- Built-in repository policy for cross-account access
- Lifecycle policies support (via repository configuration)
- Integration with ECS, Lambda, and other container services

## Usage

### Basic ECR Repository for ETL Application

```hcl
module "payer_etl_ecr" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/elastic_container_registry?ref=main"

  aws_ecr_repository_name = "partner-upload-etl"
}
```

### ECR Repository for FHIR Server

```hcl
module "fhir_server_ecr" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/elastic_container_registry?ref=main"

  aws_ecr_repository_name = "fhir-server-prod"
}
```

### Multiple Repositories for Microservices Architecture

```hcl
module "eligibility_generator_ecr" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/elastic_container_registry?ref=main"

  aws_ecr_repository_name = "eligibility-file-report-generator"
}

module "eligibility_pipeline_ecr" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/elastic_container_registry?ref=main"

  aws_ecr_repository_name = "eligibility-file-report-pipeline"
}

module "nextgate_sync_ecr" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/elastic_container_registry?ref=main"

  aws_ecr_repository_name = "nextgate-sync-service"
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
| [aws_ecr_repository.repo](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.policy-document](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ecr_repository_name"></a> [aws\_ecr\_repository\_name](#input\_aws\_ecr\_repository\_name) | (Required) Name of the ECR Repository | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_repo_name"></a> [repo\_name](#output\_repo\_name) | n/a |
<!-- END_TF_DOCS -->
