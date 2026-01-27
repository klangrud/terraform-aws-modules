# S3 Bucket Module

A Terraform module for creating secure S3 buckets with encryption, versioning, logging, and custom bucket policies.

## Features

- Server-side encryption (AWS managed keys)
- Optional versioning (Enabled, Suspended, or Disabled)
- Automatic access logging to centralized logging bucket
- Public access blocking
- Custom bucket policies
- Folder structure creation
- Force destroy option for non-production environments

## Usage

### Basic S3 Bucket

```hcl
module "s3_bucket" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket = "my-application-data"

  tags = {
    Environment = "production"
    Application = "my-app"
  }
}
```

### S3 Bucket with Versioning

```hcl
module "s3_bucket_versioned" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket     = "my-versioned-bucket"
  versioning = "Enabled"

  tags = {
    Environment = "production"
    Purpose     = "backup"
  }
}
```

### S3 Bucket with Folders and Custom Policy

```hcl
module "s3_bucket_with_folders" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket = "my-data-lake"

  bucket_folders = [
    "raw/",
    "processed/",
    "archive/"
  ]

  bucket_policies_json = [
    jsonencode({
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::123456789012:role/DataProcessingRole"
      }
      Action = [
        "s3:GetObject",
        "s3:PutObject"
      ]
      Resource = "arn:aws:s3:::my-data-lake/*"
    })
  ]

  tags = {
    Environment = "production"
    DataTier    = "raw-and-processed"
  }
}
```

### Development Bucket (Force Destroy Enabled)

```hcl
module "dev_bucket" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket        = "dev-test-bucket"
  force_destroy = true  # Allow Terraform to delete bucket even if it contains objects

  tags = {
    Environment = "development"
    CanDelete   = "true"
  }
}
```

### Bucket with Custom Logging Bucket

```hcl
module "s3_bucket_custom_logging" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket         = "my-application-data"
  logging_bucket = "my-custom-logging-bucket"

  tags = {
    Environment = "production"
  }
}
```

### Bucket Without Logging

```hcl
module "s3_bucket_no_logs" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket         = "my-bucket-no-logs"
  enable_logging = false

  tags = {
    Environment = "sandbox"
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
| <a name="provider_aws.provider"></a> [aws.provider](#provider\_aws.provider) | 6.27.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_s3_bucket.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_logging.s3_bucket_logging](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_logging) | resource |
| [aws_s3_bucket_notification.bucket_notification](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_notification) | resource |
| [aws_s3_bucket_policy.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_public_access_block.public_access_block](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_s3_bucket_server_side_encryption_configuration.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_server_side_encryption_configuration) | resource |
| [aws_s3_bucket_versioning.s3_bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_object.bucket-folders](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_object) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.bucket_merged](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.enforce-secure-transport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_s3_bucket.global-logging-bucket](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bucket"></a> [bucket](#input\_bucket) | S3 bucket name | `string` | n/a | yes |
| <a name="input_bucket_folders"></a> [bucket\_folders](#input\_bucket\_folders) | List of bucket folders to add to this bucket as aws s3 bucket objects. | `list(string)` | `[]` | no |
| <a name="input_bucket_policies_json"></a> [bucket\_policies\_json](#input\_bucket\_policies\_json) | Statement array of JSON bucket policies to combine into single bucket policy. | `list(string)` | `[]` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable S3 access logging to centralized logging bucket. Requires logs-{region}-{account\_id} bucket to exist. | `bool` | `true` | no |
| <a name="input_force_destroy"></a> [force\_destroy](#input\_force\_destroy) | When destroying this s3 bucket, it will destroy even if there are objects in the bucket | `bool` | `false` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | n/a | yes |
| <a name="input_versioning"></a> [versioning](#input\_versioning) | Bucket Versioning (Enabled, Suspended, or Disabled) | `string` | `"Disabled"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aws_s3_bucket_arn"></a> [aws\_s3\_bucket\_arn](#output\_aws\_s3\_bucket\_arn) | n/a |
| <a name="output_aws_s3_bucket_id"></a> [aws\_s3\_bucket\_id](#output\_aws\_s3\_bucket\_id) | n/a |
| <a name="output_aws_s3_bucket_name"></a> [aws\_s3\_bucket\_name](#output\_aws\_s3\_bucket\_name) | n/a |
| <a name="output_aws_s3_bucket_region"></a> [aws\_s3\_bucket\_region](#output\_aws\_s3\_bucket\_region) | n/a |
| <a name="output_aws_s3_bucket_versioning"></a> [aws\_s3\_bucket\_versioning](#output\_aws\_s3\_bucket\_versioning) | n/a |
<!-- END_TF_DOCS -->
