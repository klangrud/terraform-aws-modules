# S3 Bucket Replication Module

This module provides flexible S3 replication capabilities with support for:
- **Flexible bucket management**: Create or use existing buckets in any combination
- **Bidirectional replication**: Single module call with `enable_bidirectional=true`
- **Smart IAM role detection**: Use existing roles or create new ones automatically
- **Cross-account support**: Replication between buckets in different AWS accounts
- **Cross-region support**: Disaster recovery scenarios with buckets in different regions

## Features

- ✅ Create both source and destination buckets, or use existing ones
- ✅ Bidirectional replication with single module invocation
- ✅ Automatic IAM role creation with proper permissions
- ✅ Support for existing IAM replication roles
- ✅ Cross-account ownership transfer
- ✅ Configurable prefix filters for replication rules
- ✅ Delete marker replication support
- ✅ Automatic versioning enablement

## Prerequisites

- Terraform >= 1.0
- AWS Provider >= 4.0
- S3 buckets must have versioning enabled (module handles this automatically)
- Appropriate IAM permissions to create/manage S3 buckets, IAM roles, and replication configurations

## Usage Examples

### Example 1: Disaster Recovery (Create Both Buckets, Same Account)

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "aws-primary"  # AWS profile from ~/.aws/config
  alias   = "primary"
}

provider "aws" {
  region  = "us-west-2"
  profile = "aws-primary"
  alias   = "dr"
}

module "dr_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "my-app-primary"
  destination_bucket_name = "my-app-dr"
  source_account_id       = "123456789012"
  destination_account_id  = "123456789012"

  # Uses AWS defaults: no delete marker replication, inherits source storage class
  replication_rules = [
    { prefix = "" }  # Replicate all objects
  ]

  tags = {
    Environment = "production"
    Purpose     = "disaster-recovery"
  }

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.dr
  }
}
```

### Example 2: Bidirectional Cross-Account Replication

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "aws-primary"
  alias   = "account_a"
  assume_role {
    role_arn = "arn:aws:iam::111111111111:role/terraform-deployment-role"
  }
}

provider "aws" {
  region  = "us-east-1"
  profile = "aws-secondary"
  alias   = "account_b"
  assume_role {
    role_arn = "arn:aws:iam::222222222222:role/terraform-deployment-role"
  }
}

module "bidirectional_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "account-a-shared"
  destination_bucket_name = "account-b-shared"
  source_account_id       = "111111111111"
  destination_account_id  = "222222222222"

  enable_bidirectional = true

  # Multiple rules for each direction (auto-assigned priorities: 1, 2, 3, 4)
  replication_rules = [
    { prefix = "to-b/data/" },
    { prefix = "to-b/logs/" }
  ]

  reverse_replication_rules = [
    { prefix = "to-a/reports/" },
    { prefix = "to-a/backups/" }
  ]

  tags = {
    Environment = "production"
    Purpose     = "cross-account-sync"
  }

  providers = {
    aws.source      = aws.account_a
    aws.destination = aws.account_b
  }
}
```

### Example 3: Existing Source, Create Destination

```hcl
module "backup_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name        = "existing-production-bucket"
  source_bucket_exists      = true  # Don't create, just configure replication

  destination_bucket_name   = "new-backup-bucket"
  destination_bucket_exists = false # Create this bucket

  source_account_id      = "123456789012"
  destination_account_id = "123456789012"

  # Only replicate specific prefixes
  replication_rules = [
    { prefix = "data/" },
    { prefix = "logs/" }
  ]

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.backup
  }
}
```

### Example 4: Both Buckets Exist (Replication Only)

```hcl
module "configure_replication_only" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name        = "existing-source"
  source_bucket_exists      = true

  destination_bucket_name   = "existing-destination"
  destination_bucket_exists = true

  source_account_id      = "123456789012"
  destination_account_id = "987654321098"

  providers = {
    aws.source      = aws.account1
    aws.destination = aws.account2
  }
}
```

### Example 5: Use Existing IAM Roles

```hcl
module "replication_with_existing_roles" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "my-bucket"
  destination_bucket_name = "my-backup"
  source_account_id       = "123456789012"
  destination_account_id  = "123456789012"

  # Use pre-existing IAM role
  source_replication_role_arn = "arn:aws:iam::123456789012:role/existing-replication-role"

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.dr
  }
}
```

### Example 6: Multiple Replication Rules with Per-Rule Settings

```hcl
module "multi_prefix_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "source-bucket"
  destination_bucket_name = "destination-bucket"
  source_account_id       = "123456789012"
  destination_account_id  = "123456789012"

  # Multiple replication rules with per-rule configuration
  # Priorities auto-assigned: 1, 2, 3, 4, 5
  replication_rules = [
    {
      prefix = "data/customers/",
      storage_class = "STANDARD"
    },
    {
      prefix = "data/orders/",
      storage_class = "STANDARD"
    },
    {
      prefix = "logs/application/",
      storage_class = "STANDARD_IA",
      delete_marker_replication = false
    },
    {
      prefix = "logs/audit/",
      storage_class = "STANDARD_IA"
    },
    {
      prefix = "archives/",
      storage_class = "GLACIER",
      delete_marker_replication = false
    }
  ]

  # No priority variables needed - automatically assigned!
  # Rule priorities will be: 1, 2, 3, 4, 5

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.dr
  }
}
```

### Example 7: Enable Delete Marker Replication

```hcl
module "delete_marker_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "source-bucket"
  destination_bucket_name = "destination-bucket"
  source_account_id       = "123456789012"
  destination_account_id  = "123456789012"

  # Enable delete marker replication (AWS default is false)
  replication_rules = [
    {
      prefix = "",
      delete_marker_replication = true  # Replicate deletions to destination
    }
  ]

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.dr
  }
}
```

### Example 8: KMS Encryption for Replicated Objects

```hcl
module "encrypted_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "source-bucket"
  destination_bucket_name = "destination-bucket"
  source_account_id       = "123456789012"
  destination_account_id  = "987654321098"

  # Encrypt replicated objects with destination KMS key
  replication_rules = [
    {
      prefix = "sensitive-data/",
      replica_kms_key_id = "arn:aws:kms:us-west-2:987654321098:key/12345678-1234-1234-1234-123456789012"
    }
  ]

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.dr
  }
}
```

### Example 9: Simple Multiple Prefixes (Bidirectional)

```hcl
module "multi_prefix_bidirectional" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "shared-bucket-a"
  destination_bucket_name = "shared-bucket-b"
  source_account_id       = "123456789012"
  destination_account_id  = "123456789012"

  enable_bidirectional = true

  # Forward replication (priorities 1, 2, 3, 4)
  replication_rules = [
    { prefix = "inbound/" },
    { prefix = "inbound2/" },
    { prefix = "inbound3/" },
    { prefix = "inbound4/" }
  ]

  # Reverse replication (priorities 5, 6, 7, 8)
  reverse_replication_rules = [
    { prefix = "outbound/" },
    { prefix = "outbound2/" },
    { prefix = "outbound3/" },
    { prefix = "outbound4/" }
  ]

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.backup
  }
}
```

### Example 10: Mixed Storage Classes and Settings

```hcl
module "tiered_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=v1.0.0"

  source_bucket_name      = "production-data"
  destination_bucket_name = "backup-data"
  source_account_id       = "123456789012"
  destination_account_id  = "123456789012"

  replication_rules = [
    {
      prefix = "hot-data/",
      storage_class = "STANDARD",
      delete_marker_replication = true
    },
    {
      prefix = "warm-data/",
      storage_class = "STANDARD_IA"
    },
    {
      prefix = "cold-data/",
      storage_class = "GLACIER"
    },
    {
      prefix = "archive/",
      storage_class = "DEEP_ARCHIVE",
      delete_marker_replication = false
    }
  ]

  providers = {
    aws.source      = aws.primary
    aws.destination = aws.dr
  }
}
```

## Key Features

### Auto-Assigned Priorities

Replication rule priorities are automatically assigned sequentially:
- **Forward replication rules** (source → destination): Priorities 1, 2, 3, ...
- **Reverse replication rules** (destination → source): Priorities N+1, N+2, N+3, ...
  - Where N is the number of forward rules

**Example with bidirectional replication:**
```hcl
replication_rules = [
  { prefix = "data/" },
  { prefix = "logs/" }
]  # Gets priorities 1, 2

reverse_replication_rules = [
  { prefix = "reports/" },
  { prefix = "backups/" }
]  # Gets priorities 3, 4
```

This prevents priority conflicts and works even if you have existing replication rules on your buckets!

### Per-Rule Configuration

Each rule in the list creates a separate replication configuration:
- **Prefix filtering**: Control which objects get replicated
- **Storage class**: Different storage tiers per rule (STANDARD, STANDARD_IA, GLACIER, etc.)
- **Delete marker replication**: Enable/disable per rule
- **KMS encryption**: Optional per-rule encryption with custom keys
- **CloudWatch metrics**: Each rule can be monitored independently

This allows you to replicate hot data to STANDARD storage while archiving logs to GLACIER, all in a single module call.

## IAM Permissions Required

### For Terraform Deployment

The IAM principal running Terraform needs:
- `s3:*` on source and destination buckets
- `iam:CreateRole`, `iam:CreatePolicy`, `iam:AttachRolePolicy`
- `iam:GetRole`, `iam:GetPolicy` (for detecting existing resources)

### Source Replication Role Permissions

Automatically created by the module:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObjectVersionForReplication",
        "s3:GetObjectVersionAcl",
        "s3:GetObjectVersionTagging",
        "s3:GetObjectRetention",
        "s3:GetObjectLegalHold"
      ],
      "Resource": ["arn:aws:s3:::source-bucket/*"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket",
        "s3:GetReplicationConfiguration"
      ],
      "Resource": ["arn:aws:s3:::source-bucket"]
    },
    {
      "Effect": "Allow",
      "Action": [
        "s3:ReplicateObject",
        "s3:ReplicateDelete",
        "s3:ReplicateTags",
        "s3:ObjectOwnerOverrideToBucketOwner"
      ],
      "Resource": ["arn:aws:s3:::destination-bucket/*"]
    }
  ]
}
```

## Troubleshooting

### Error: "InvalidRequest: Versioning must be enabled"

**Solution**: The module automatically enables versioning on both buckets. If you see this error, ensure the `depends_on` blocks in replication configurations are working correctly.

### Error: "AccessDenied: Access Denied"

**Solution**: Verify that:
1. The replication role has permissions to read from source and write to destination
2. The destination bucket policy allows the replication role to write objects
3. Cross-account trust relationships are correctly configured

### Replication Not Working

**Checklist**:
1. Verify versioning is enabled: `aws s3api get-bucket-versioning --bucket <bucket-name>`
2. Check replication configuration: `aws s3api get-bucket-replication --bucket <source-bucket>`
3. Verify IAM role permissions and trust relationships
4. Check CloudWatch metrics for replication (can take up to 15 minutes for first replication)

### Circular Dependency Errors

The module handles dependencies automatically. If you encounter circular dependency errors:
1. Ensure you're using the latest version of the module
2. Verify provider aliases are correctly configured
3. Check that bucket policies are not being applied outside the module

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Replication Flow                          │
└─────────────────────────────────────────────────────────────┘

Account A (Source)                    Account B (Destination)
┌──────────────────┐                 ┌──────────────────┐
│  Source Bucket   │  ────────────>  │ Destination      │
│  (Versioned)     │                 │ Bucket           │
│                  │                 │ (Versioned)      │
└──────────────────┘                 └──────────────────┘
         │                                     ▲
         │                                     │
         ▼                                     │
┌──────────────────┐                          │
│ Source Replic.   │  ─────────────────────────
│ IAM Role         │
└──────────────────┘

Bidirectional (optional):
Account B → Account A uses separate role and replication config
```

## Migration from s3_bucket_with_dr_backup

If you're migrating from the `s3_bucket_with_dr_backup` module:

1. **Import existing buckets**:
   ```bash
   terraform import 'module.new_replication.data.aws_s3_bucket.source_existing[0]' source-bucket-name
   terraform import 'module.new_replication.data.aws_s3_bucket.destination_existing[0]' dest-bucket-name
   ```

2. **Set existence flags**:
   ```hcl
   source_bucket_exists      = true
   destination_bucket_exists = true
   ```

3. **Import replication configuration**:
   ```bash
   terraform import 'module.new_replication.aws_s3_bucket_replication_configuration.source_to_destination' source-bucket-name
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
| <a name="provider_aws.destination"></a> [aws.destination](#provider\_aws.destination) | >= 4.0 |
| <a name="provider_aws.source"></a> [aws.source](#provider\_aws.source) | >= 4.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_destination_bucket"></a> [destination\_bucket](#module\_destination\_bucket) | git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket | main |
| <a name="module_source_bucket"></a> [source\_bucket](#module\_source\_bucket) | git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket | main |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy.destination_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.source_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.destination_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.source_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.destination_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.source_replication](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_s3_bucket_policy.destination_existing_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_policy.source_existing_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_policy) | resource |
| [aws_s3_bucket_replication_configuration.destination_to_source](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_replication_configuration.source_to_destination](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_replication_configuration) | resource |
| [aws_s3_bucket_versioning.destination_existing_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_s3_bucket_versioning.source_existing_versioning](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_versioning) | resource |
| [aws_iam_policy_document.destination_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.source_bucket_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_s3_bucket.destination_existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |
| [aws_s3_bucket.source_existing](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/s3_bucket) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_destination_account_id"></a> [destination\_account\_id](#input\_destination\_account\_id) | AWS Account ID for destination bucket | `string` | n/a | yes |
| <a name="input_destination_bucket_exists"></a> [destination\_bucket\_exists](#input\_destination\_bucket\_exists) | Set to true if destination bucket already exists and should not be created | `bool` | `false` | no |
| <a name="input_destination_bucket_folders"></a> [destination\_bucket\_folders](#input\_destination\_bucket\_folders) | List of folders to create in destination bucket (only if creating new bucket) | `list(string)` | `[]` | no |
| <a name="input_destination_bucket_name"></a> [destination\_bucket\_name](#input\_destination\_bucket\_name) | Name of the destination S3 bucket for replication | `string` | n/a | yes |
| <a name="input_destination_bucket_policies_json"></a> [destination\_bucket\_policies\_json](#input\_destination\_bucket\_policies\_json) | Additional bucket policies for destination bucket (only if creating new bucket) | `list(string)` | `[]` | no |
| <a name="input_destination_replication_role_arn"></a> [destination\_replication\_role\_arn](#input\_destination\_replication\_role\_arn) | Existing IAM role ARN for dest→source replication (bidirectional only). If null, module will create one | `string` | `null` | no |
| <a name="input_destination_replication_role_name"></a> [destination\_replication\_role\_name](#input\_destination\_replication\_role\_name) | Name for IAM replication role (dest→source). Defaults to 'replication-role-{destination\_bucket\_name}' | `string` | `null` | no |
| <a name="input_enable_bidirectional"></a> [enable\_bidirectional](#input\_enable\_bidirectional) | Enable bidirectional replication (both source→dest and dest→source) | `bool` | `false` | no |
| <a name="input_enable_logging"></a> [enable\_logging](#input\_enable\_logging) | Enable S3 access logging for created buckets. Requires logs-{region}-{account\_id} bucket to exist in each provider account. | `bool` | `false` | no |
| <a name="input_force_destroy_buckets"></a> [force\_destroy\_buckets](#input\_force\_destroy\_buckets) | Allow destruction of buckets even if they contain objects | `bool` | `false` | no |
| <a name="input_replication_rules"></a> [replication\_rules](#input\_replication\_rules) | List of replication rules for source→destination replication. Each rule creates a separate replication configuration.<br><br>Fields:<br>- prefix: Object key prefix for filtering (empty string means replicate all objects)<br>- delete\_marker\_replication: Enable delete marker replication (default: false, matches AWS default)<br>- storage\_class: Storage class for replicated objects (default: null, uses source object's storage class). Valid values: STANDARD, REDUCED\_REDUNDANCY, STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, DEEP\_ARCHIVE<br>- replica\_kms\_key\_id: KMS key ID for encrypting replicas (optional) | <pre>list(object({<br>    prefix                    = string<br>    delete_marker_replication = optional(bool, false)<br>    storage_class             = optional(string, null)<br>    replica_kms_key_id        = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "prefix": ""<br>  }<br>]</pre> | no |
| <a name="input_reverse_replication_rules"></a> [reverse\_replication\_rules](#input\_reverse\_replication\_rules) | List of replication rules for destination→source replication (only used if enable\_bidirectional=true).<br><br>Fields:<br>- prefix: Object key prefix for filtering (empty string means replicate all objects)<br>- delete\_marker\_replication: Enable delete marker replication (default: false, matches AWS default)<br>- storage\_class: Storage class for replicated objects (default: null, uses source object's storage class). Valid values: STANDARD, REDUCED\_REDUNDANCY, STANDARD\_IA, ONEZONE\_IA, INTELLIGENT\_TIERING, GLACIER, DEEP\_ARCHIVE<br>- replica\_kms\_key\_id: KMS key ID for encrypting replicas (optional) | <pre>list(object({<br>    prefix                    = string<br>    delete_marker_replication = optional(bool, false)<br>    storage_class             = optional(string, null)<br>    replica_kms_key_id        = optional(string, null)<br>  }))</pre> | <pre>[<br>  {<br>    "prefix": ""<br>  }<br>]</pre> | no |
| <a name="input_source_account_id"></a> [source\_account\_id](#input\_source\_account\_id) | AWS Account ID for source bucket | `string` | n/a | yes |
| <a name="input_source_bucket_exists"></a> [source\_bucket\_exists](#input\_source\_bucket\_exists) | Set to true if source bucket already exists and should not be created | `bool` | `false` | no |
| <a name="input_source_bucket_folders"></a> [source\_bucket\_folders](#input\_source\_bucket\_folders) | List of folders to create in source bucket (only if creating new bucket) | `list(string)` | `[]` | no |
| <a name="input_source_bucket_name"></a> [source\_bucket\_name](#input\_source\_bucket\_name) | Name of the source S3 bucket for replication | `string` | n/a | yes |
| <a name="input_source_bucket_policies_json"></a> [source\_bucket\_policies\_json](#input\_source\_bucket\_policies\_json) | Additional bucket policies for source bucket (only if creating new bucket) | `list(string)` | `[]` | no |
| <a name="input_source_replication_role_arn"></a> [source\_replication\_role\_arn](#input\_source\_replication\_role\_arn) | Existing IAM role ARN for source→dest replication. If null, module will create one | `string` | `null` | no |
| <a name="input_source_replication_role_name"></a> [source\_replication\_role\_name](#input\_source\_replication\_role\_name) | Name for IAM replication role (source→dest). Defaults to 'replication-role-{source\_bucket\_name}' | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_destination_bucket_arn"></a> [destination\_bucket\_arn](#output\_destination\_bucket\_arn) | ARN of the destination bucket |
| <a name="output_destination_bucket_name"></a> [destination\_bucket\_name](#output\_destination\_bucket\_name) | Name of the destination bucket |
| <a name="output_destination_replication_role_arn"></a> [destination\_replication\_role\_arn](#output\_destination\_replication\_role\_arn) | ARN of the IAM role used for destination → source replication (null if not bidirectional) |
| <a name="output_is_bidirectional"></a> [is\_bidirectional](#output\_is\_bidirectional) | Whether bidirectional replication is enabled |
| <a name="output_is_cross_account"></a> [is\_cross\_account](#output\_is\_cross\_account) | Whether this is cross-account replication |
| <a name="output_replication_configuration_id"></a> [replication\_configuration\_id](#output\_replication\_configuration\_id) | ID of the source → destination replication configuration |
| <a name="output_source_bucket_arn"></a> [source\_bucket\_arn](#output\_source\_bucket\_arn) | ARN of the source bucket |
| <a name="output_source_bucket_name"></a> [source\_bucket\_name](#output\_source\_bucket\_name) | Name of the source bucket |
| <a name="output_source_replication_role_arn"></a> [source\_replication\_role\_arn](#output\_source\_replication\_role\_arn) | ARN of the IAM role used for source → destination replication |
<!-- END_TF_DOCS -->
