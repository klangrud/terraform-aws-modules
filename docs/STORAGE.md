# Storage & Data Modules

Modules for managing S3 storage with security, compliance, and disaster recovery capabilities.

## Table of Contents

- [s3_bucket](#s3_bucket)
- [s3_bucket_replication](#s3_bucket_replication)

---

## s3_bucket

### Overview

Base module for creating secure, compliant S3 buckets with encryption, versioning, logging, and flexible policy management.

### Key Features

- **Security by Default**: AES256 encryption, blocks all public access
- **Access Logging**: Automatic logging to organization's global logging bucket
- **Versioning**: Optional versioning (Enabled/Suspended/Disabled)
- **Policy Merging**: Combines multiple policy statements into single bucket policy
- **Folder Creation**: Creates S3 "folders" as bucket objects
- **Notifications**: Optional S3 event notifications

### Architecture

```
┌──────────────────────────────────────────────┐
│ S3 Bucket                                     │
│                                               │
│ ├── Versioning (optional)                    │
│ ├── Server-Side Encryption (AES256)          │
│ ├── Public Access Block (all blocked)        │
│ ├── Bucket Policy (merged statements)        │
│ ├── Access Logging → Global Logging Bucket   │
│ └── Event Notifications (optional)           │
└──────────────────────────────────────────────┘
```

### Usage Examples

#### Basic Secure Bucket

```hcl
module "data_bucket" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket = "my-data-bucket-prod"

  tags = {
    Environment = "production"
    Purpose     = "data-storage"
  }
}
```

#### Bucket with Versioning and Folders

```hcl
module "archive_bucket" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket     = "archive-bucket-prod"
  versioning = "Enabled"

  bucket_folders = [
    "inbound/",
    "processed/",
    "archive/2024/",
    "archive/2025/"
  ]

  tags = {
    Environment = "production"
    DataClass   = "archive"
  }
}
```

#### Bucket with Custom Policies

```hcl
module "app_bucket" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket = "app-assets-prod"

  bucket_policies_json = [
    # Allow CloudFront OAI to read
    jsonencode({
      Sid    = "AllowCloudFrontOAI"
      Effect = "Allow"
      Principal = {
        AWS = "arn:aws:iam::cloudfront:user/CloudFront Origin Access Identity E1234567890ABC"
      }
      Action   = "s3:GetObject"
      Resource = "arn:aws:s3:::app-assets-prod/*"
    }),
    # Allow Lambda function to write
    jsonencode({
      Sid    = "AllowLambdaWrite"
      Effect = "Allow"
      Principal = {
        AWS = aws_iam_role.lambda_role.arn
      }
      Action = [
        "s3:PutObject",
        "s3:PutObjectAcl"
      ]
      Resource = "arn:aws:s3:::app-assets-prod/uploads/*"
    })
  ]

  tags = {
    Environment = "production"
    Application = "web-app"
  }
}
```

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `bucket` | string | S3 bucket name (must be globally unique) |
| `tags` | map(string) | Resource tags |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `versioning` | string | "Disabled" | Versioning: Enabled, Suspended, or Disabled |
| `force_destroy` | bool | false | Allow destroy even with objects |
| `bucket_policies_json` | list(string) | [] | JSON policy statements to merge |
| `bucket_folders` | list(string) | [] | Folder paths to create |

### Outputs

| Output | Description |
|--------|-------------|
| `aws_s3_bucket_id` | Bucket ID (same as name) |
| `aws_s3_bucket_name` | Bucket name |
| `aws_s3_bucket_arn` | Bucket ARN |
| `aws_s3_bucket_region` | Bucket region |
| `aws_s3_bucket_versioning` | Versioning status |

### Security Features

1. **Encryption**: AES256 server-side encryption (default AWS-managed keys)
2. **Public Access**: All public access blocked by default
3. **Secure Transport**: Enforced via bucket policy
4. **Access Logging**: All access logged to central logging bucket

### Best Practices

1. **Bucket Naming**: Use descriptive names with environment suffix
2. **Versioning**: Enable for critical data buckets
3. **Lifecycle Policies**: Add lifecycle rules separately for cost optimization
4. **Cross-Region**: Use `s3_bucket_replication` for DR requirements
5. **Policy Management**: Use `bucket_policies_json` for complex policies

---

## s3_bucket_replication

### Overview

Flexible S3 replication module that supports creating or using existing buckets with bidirectional cross-account/cross-region replication. Ideal for disaster recovery, cross-account data sharing, and complex replication scenarios.

### Key Features

- **Flexible Bucket Management**: Create or use existing buckets in any combination
- **Bidirectional Replication**: Single module call with `enable_bidirectional=true`
- **Smart IAM Role Detection**: Use existing roles or create new ones automatically
- **Per-Rule Configuration**: Different storage classes, delete marker settings, and KMS encryption per prefix
- **Auto-Assigned Priorities**: Automatic priority assignment prevents conflicts
- **Cross-Account Support**: Replication between buckets in different AWS accounts
- **Cross-Region Support**: Disaster recovery scenarios with buckets in different regions
- **Multiple Prefix Filters**: Create unlimited replication rules with different prefixes

### Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Account A (Source)                                          │
│                                                             │
│  ┌─────────────────────────────────────┐                   │
│  │ Source Bucket                       │                   │
│  │ (Created or Existing)               │                   │
│  │                                      │                   │
│  │ • Versioning: Enabled (auto)        │                   │
│  │ • Encryption: AES256                │                   │
│  │ • Multiple Replication Rules        │                   │
│  │   - Rule 1: Priority 1              │                   │
│  │   - Rule 2: Priority 2              │                   │
│  │   - Rule N: Priority N              │                   │
│  └────────────┬─────────────────────────┘                   │
│               │                                             │
│  ┌────────────┴──────────────────┐                          │
│  │ Source Replication IAM Role   │                          │
│  │ (Created or Existing)         │                          │
│  │                                │                          │
│  │ Permissions:                   │                          │
│  │ • Read from source             │                          │
│  │ • Write to destination         │                          │
│  │ • ObjectOwnerOverride          │                          │
│  └────────────────────────────────┘                          │
└──────────────────┼──────────────────────────────────────────┘
                   │ Cross-Account/Region
                   │ Replication
                   ▼
┌─────────────────────────────────────────────────────────────┐
│ Account B (Destination)                                     │
│                                                             │
│  ┌─────────────────────────────────────┐                   │
│  │ Destination Bucket                  │                   │
│  │ (Created or Existing)               │                   │
│  │                                      │                   │
│  │ • Versioning: Enabled (auto)        │                   │
│  │ • Encryption: AES256                │                   │
│  │ • Bucket Policy: Allows source      │                   │
│  └─────────────────────────────────────┘                   │
│               ▲                                             │
│               │ Reverse Replication (Optional)              │
│  ┌────────────┴──────────────────┐                          │
│  │ Destination Replication Role  │                          │
│  │ (If bidirectional enabled)    │                          │
│  │                                │                          │
│  │ Priorities:                    │                          │
│  │ • Rule 1: Priority N+1         │                          │
│  │ • Rule 2: Priority N+2         │                          │
│  └────────────────────────────────┘                          │
└─────────────────────────────────────────────────────────────┘
```

### Usage Examples

#### Example 1: Disaster Recovery (Same Account, Different Regions)

```hcl
provider "aws" {
  region  = "us-east-1"
  profile = "aws-primary"
  alias   = "primary"
}

provider "aws" {
  region  = "us-west-2"
  profile = "aws-primary"
  alias   = "dr"
}

module "dr_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=main"

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

#### Example 2: Bidirectional Cross-Account Replication

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
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=main"

  source_bucket_name      = "account-a-shared"
  destination_bucket_name = "account-b-shared"
  source_account_id       = "111111111111"
  destination_account_id  = "222222222222"

  enable_bidirectional = true

  # Forward replication (priorities: 1, 2)
  replication_rules = [
    { prefix = "to-b/data/" },
    { prefix = "to-b/logs/" }
  ]

  # Reverse replication (priorities: 3, 4)
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

#### Example 3: Existing Buckets with Multiple Prefixes

```hcl
module "configure_replication_only" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=main"

  source_bucket_name        = "existing-source"
  source_bucket_exists      = true
  destination_bucket_name   = "existing-destination"
  destination_bucket_exists = true

  source_account_id      = "123456789012"
  destination_account_id = "987654321098"

  # Multiple prefixes with per-rule configuration
  replication_rules = [
    {
      prefix = "inbound/",
      storage_class = "STANDARD"
    },
    {
      prefix = "inbound2/",
      storage_class = "STANDARD_IA"
    },
    {
      prefix = "archives/",
      storage_class = "GLACIER",
      delete_marker_replication = false
    }
  ]

  providers = {
    aws.source      = aws.account1
    aws.destination = aws.account2
  }
}
```

#### Example 4: Mixed Storage Classes with KMS Encryption

```hcl
module "tiered_replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=main"

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
      prefix = "sensitive/",
      storage_class = "STANDARD",
      replica_kms_key_id = "arn:aws:kms:us-west-2:123456789012:key/abc-123"
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

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `source_bucket_name` | string | Source S3 bucket name |
| `destination_bucket_name` | string | Destination S3 bucket name |
| `source_account_id` | string | AWS Account ID for source bucket |
| `destination_account_id` | string | AWS Account ID for destination bucket |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `source_bucket_exists` | bool | false | Set true if source bucket exists |
| `destination_bucket_exists` | bool | false | Set true if destination bucket exists |
| `enable_bidirectional` | bool | false | Enable bidirectional replication |
| `replication_rules` | list(object) | `[{prefix=""}]` | Forward replication rules |
| `reverse_replication_rules` | list(object) | `[{prefix=""}]` | Reverse replication rules |
| `source_replication_role_arn` | string | null | Existing source→dest IAM role ARN |
| `destination_replication_role_arn` | string | null | Existing dest→source IAM role ARN |
| `source_bucket_folders` | list(string) | [] | Folders to create (if creating bucket) |
| `destination_bucket_folders` | list(string) | [] | Folders to create (if creating bucket) |
| `force_destroy_buckets` | bool | false | Allow destroy even with objects |
| `tags` | map(string) | {} | Resource tags |

#### Replication Rule Object

Each rule in `replication_rules` or `reverse_replication_rules`:

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `prefix` | string | Required | Object key prefix filter |
| `delete_marker_replication` | bool | false | Enable delete marker replication (AWS default) |
| `storage_class` | string | null | Storage class (null = use source object's class) |
| `replica_kms_key_id` | string | null | KMS key for replica encryption |

**Valid Storage Classes**: STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE

### Outputs

| Output | Description |
|--------|-------------|
| `source_bucket_arn` | ARN of the source bucket |
| `source_bucket_name` | Name of the source bucket |
| `destination_bucket_arn` | ARN of the destination bucket |
| `destination_bucket_name` | Name of the destination bucket |
| `source_replication_role_arn` | ARN of source→dest replication IAM role |
| `destination_replication_role_arn` | ARN of dest→source replication IAM role (if bidirectional) |
| `is_cross_account` | Whether this is cross-account replication |
| `is_bidirectional` | Whether bidirectional replication is enabled |

### Key Features Detail

#### Auto-Assigned Priorities

Replication rule priorities are automatically assigned sequentially:
- **Forward replication rules** (source → destination): Priorities 1, 2, 3, ...
- **Reverse replication rules** (destination → source): Priorities N+1, N+2, N+3, ...
  - Where N is the number of forward rules

This prevents priority conflicts and works even if you have existing replication rules on your buckets.

#### Per-Rule Configuration

Each rule in the list creates a separate replication configuration:
- **Prefix filtering**: Control which objects get replicated
- **Storage class**: Different storage tiers per rule (STANDARD, STANDARD_IA, GLACIER, etc.)
- **Delete marker replication**: Enable/disable per rule
- **KMS encryption**: Optional per-rule encryption with custom keys

This allows you to replicate hot data to STANDARD storage while archiving logs to GLACIER, all in a single module call.

#### AWS Defaults

The module uses AWS S3 replication defaults:
- **Delete marker replication**: Disabled (false) - matches AWS default
- **Storage class**: null (uses source object's storage class) - matches AWS default

### Cost Considerations

- **Cross-Region Replication**: ~$0.02/GB for data transfer between regions
- **Cross-Account Replication**: Same-region is free, cross-region has transfer costs
- **Storage Costs**: Pay for storage in both source and destination buckets
- **Request Costs**: PUT/COPY requests for replicated objects
- **Storage Class Optimization**: Use GLACIER or DEEP_ARCHIVE for archives to reduce costs

### Security Features

1. **Encryption**: AES256 server-side encryption on all buckets
2. **Cross-Account Ownership**: `ObjectOwnerOverrideToBucketOwner` for cross-account transfers
3. **IAM Least Privilege**: Replication roles have minimal required permissions
4. **Versioning**: Required and automatically enabled for replication
5. **KMS Support**: Optional per-rule KMS encryption

### Best Practices

1. **Bucket Existence Flags**: Always set `*_bucket_exists` flags correctly to avoid errors
2. **Prefix Separation**: Use different prefixes for bidirectional replication to avoid loops
3. **Storage Class Selection**: Match storage class to data access patterns
4. **Delete Marker Replication**: Enable only if you need to replicate deletions
5. **Monitoring**: Monitor replication metrics in CloudWatch
6. **Testing**: Test with small files before enabling for production data
7. **IAM Roles**: Reuse existing IAM roles when possible to reduce resource count

### Common Scenarios

#### Scenario 1: DR for Production Bucket
- **Goal**: Replicate production data to DR region
- **Configuration**: Single-direction replication, all objects, same storage class
- **Example**: Example 1 (Disaster Recovery)

#### Scenario 2: Cross-Account Data Sharing
- **Goal**: Share specific data folders between accounts
- **Configuration**: Bidirectional with different prefixes per direction
- **Example**: Example 2 (Bidirectional Cross-Account)

#### Scenario 3: Adding Replication to Existing Buckets
- **Goal**: Configure replication without creating new buckets
- **Configuration**: Set both `*_bucket_exists = true`
- **Example**: Example 3 (Existing Buckets)

#### Scenario 4: Tiered Storage DR
- **Goal**: Replicate with different storage classes per data type
- **Configuration**: Multiple rules with different storage classes
- **Example**: Example 4 (Mixed Storage Classes)

### Troubleshooting

#### Error: "Versioning must be enabled"
**Solution**: The module automatically enables versioning. Ensure `depends_on` blocks are working correctly.

#### Error: "AccessDenied"
**Solution**: Verify:
1. Replication role has permissions to read from source and write to destination
2. Destination bucket policy allows the replication role
3. Cross-account trust relationships are configured

#### Replication Not Working
**Checklist**:
1. Verify versioning: `aws s3api get-bucket-versioning --bucket <bucket-name>`
2. Check replication config: `aws s3api get-bucket-replication --bucket <source-bucket>`
3. Verify IAM role permissions and trust relationships
4. Check CloudWatch metrics (can take 15 minutes for first replication)
5. Verify prefixes match expected objects

#### Priority Conflicts
The module auto-assigns priorities to prevent conflicts. If you see priority errors, existing replication rules on the bucket may conflict. Consider:
1. Removing existing rules before applying
2. Importing existing rules into Terraform state
3. Using different priority ranges

### Related Modules

- **s3_bucket**: Base module for individual buckets
