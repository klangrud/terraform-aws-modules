# Bootstrap & Foundation Modules

Modules for setting up foundational Terraform infrastructure including state management and utility components.

## Table of Contents

- [bootstrap_terraform](#bootstrap_terraform)
- [elastic_container_registry](#elastic_container_registry)

---

## bootstrap_terraform

### Overview

Bootstraps Terraform infrastructure by setting up remote state backend (S3 + DynamoDB) and creating a Terraform service role with configurable permissions. This is typically the first module deployed in a new AWS account.

### Key Features

- **Remote State Backend**: S3 bucket with versioning and encryption
- **State Locking**: DynamoDB table for concurrent access control
- **Service Role**: IAM role for Terraform operations with customizable policies
- **Cross-Account Support**: Configure for infrastructure account access
- **Session Management**: Configurable session timeout for security

### Architecture

```
┌────────────────────────────────────────────────────────┐
│ AWS Account (123456789012)                             │
│                                                        │
│  ┌──────────────────────────────────────────┐         │
│  │ S3 Bucket                                 │         │
│  │ terraform-state-prod                      │         │
│  │                                           │         │
│  │ • Versioning: Enabled                    │         │
│  │ • Encryption: AES256                     │         │
│  │ • Contents:                              │         │
│  │   ├── prod/vpc/terraform.tfstate         │         │
│  │   ├── prod/app/terraform.tfstate         │         │
│  │   └── prod/data/terraform.tfstate        │         │
│  └──────────────────────────────────────────┘         │
│                                                        │
│  ┌──────────────────────────────────────────┐         │
│  │ DynamoDB Table                            │         │
│  │ terraform-locks-prod                      │         │
│  │                                           │         │
│  │ • Partition Key: LockID (string)         │         │
│  │ • On-Demand Billing                      │         │
│  │ • Point-in-Time Recovery: Enabled        │         │
│  └──────────────────────────────────────────┘         │
│                                                        │
│  ┌──────────────────────────────────────────┐         │
│  │ IAM Role                                  │         │
│  │ terraform-service-role                    │         │
│  │                                           │         │
│  │ • Trust: Infrastructure account (optional)│         │
│  │ • Policy: AdministratorAccess (default)  │         │
│  │ • Session: 1 hour (default)              │         │
│  └──────────────────────────────────────────┘         │
└────────────────────────────────────────────────────────┘
```

### Usage Examples

#### Basic Bootstrap - New Account

```hcl
# First, use local state
terraform {
  # No backend configuration yet
}

module "bootstrap" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/bootstrap_terraform?ref=main"

  s3_bucket_name      = "terraform-state-prod-123456789012"
  dynamodb_table_name = "terraform-locks-prod"
  aws_account_id      = "123456789012"

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# After initial apply, migrate to remote backend:
# 1. Add backend configuration below
# 2. Run: terraform init -migrate-state
# 3. Verify state in S3
# 4. Remove local terraform.tfstate

# terraform {
#   backend "s3" {
#     bucket         = "terraform-state-prod-123456789012"
#     key            = "bootstrap/terraform.tfstate"
#     region         = "us-east-2"
#     dynamodb_table = "terraform-locks-prod"
#     encrypt        = true
#   }
# }
```

#### Bootstrap with Custom Service Role Permissions

```hcl
module "bootstrap_limited_permissions" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/bootstrap_terraform?ref=main"

  s3_bucket_name      = "terraform-state-dev-123456789012"
  dynamodb_table_name = "terraform-locks-dev"
  aws_account_id      = "123456789012"

  # Custom policies instead of AdministratorAccess
  aws_policy_arns_terraform_service_role = [
    "arn:aws:iam::aws:policy/AmazonEC2FullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/IAMFullAccess",
    "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  ]

  # Shorter session timeout for dev environment
  max_session_timeout_terraform_service_role = 1800  # 30 minutes

  tags = {
    Environment = "development"
    Purpose     = "terraform-automation"
  }
}
```

#### Cross-Account Bootstrap (Infrastructure Account Pattern)

```hcl
# Deploy in target account (123456789012)
# Allow access from infrastructure account (123456789012)

module "bootstrap_cross_account" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/bootstrap_terraform?ref=main"

  s3_bucket_name      = "terraform-state-prod-123456789012"
  dynamodb_table_name = "terraform-locks-prod"
  aws_account_id      = "123456789012"

  # Infrastructure account that will assume this role
  infra_account_id = "123456789012"

  # Extended session for CI/CD pipelines
  max_session_timeout_terraform_service_role = 7200  # 2 hours

  tags = {
    Environment = "production"
    ManagedBy   = "infrastructure-account"
  }
}
```

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `s3_bucket_name` | string | S3 bucket name for Terraform state |
| `dynamodb_table_name` | string | DynamoDB table for state locking |
| `aws_account_id` | string | AWS account ID |
| `tags` | map(string) | Resource tags |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `infra_account_id` | string | "123456789012" | Infrastructure account ID |
| `aws_policy_arns_terraform_service_role` | list(string) | ["AdministratorAccess"] | IAM policies for service role |
| `max_session_timeout_terraform_service_role` | number | 3600 | Session timeout in seconds |

### Post-Bootstrap Steps

#### 1. Migrate Local State to S3

After initial bootstrap deployment:

```bash
# 1. Add backend configuration to your Terraform
cat >> main.tf <<EOF
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod-123456789012"
    key            = "bootstrap/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-prod"
    encrypt        = true
  }
}
EOF

# 2. Initialize and migrate state
terraform init -migrate-state

# 3. Verify state in S3
aws s3 ls s3://terraform-state-prod-123456789012/

# 4. Remove local state file
rm terraform.tfstate terraform.tfstate.backup
```

#### 2. Configure Other Projects

Use the bootstrapped backend in all other Terraform projects:

```hcl
# projects/vpc/main.tf
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod-123456789012"
    key            = "prod/vpc/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-prod"
    encrypt        = true
  }
}
```

#### 3. Assume Service Role (for Cross-Account)

From infrastructure account:

```bash
# Assume role
aws sts assume-role \
  --role-arn "arn:aws:iam::123456789012:role/terraform-service-role" \
  --role-session-name "terraform-session"

# Use returned credentials in CI/CD or AWS CLI
export AWS_ACCESS_KEY_ID="..."
export AWS_SECRET_ACCESS_KEY="..."
export AWS_SESSION_TOKEN="..."
```

### State File Organization

Recommended directory structure for state files:

```
s3://terraform-state-prod/
├── bootstrap/
│   └── terraform.tfstate
├── prod/
│   ├── networking/
│   │   └── terraform.tfstate
│   ├── compute/
│   │   └── terraform.tfstate
│   ├── data/
│   │   └── terraform.tfstate
│   └── security/
│       └── terraform.tfstate
├── uat/
│   └── ...
└── dev/
    └── ...
```

### Security Best Practices

1. **Bucket Naming**: Include account ID to ensure global uniqueness
2. **Encryption**: Always enable encryption (default in module)
3. **Versioning**: Enabled by default for state recovery
4. **Access Control**: Restrict S3 bucket to Terraform service role only
5. **State Locking**: Prevents concurrent modifications
6. **Least Privilege**: Use minimal necessary policies instead of AdministratorAccess in production

### State Locking

DynamoDB table prevents concurrent Terraform operations:

```bash
# Terraform automatically acquires lock
terraform apply

# If lock is stuck (after crashed operation)
terraform force-unlock LOCK_ID

# View lock information
aws dynamodb get-item \
  --table-name terraform-locks-prod \
  --key '{"LockID":{"S":"terraform-state-prod/prod/vpc/terraform.tfstate"}}'
```

### Disaster Recovery

#### Backup State Files

```bash
# Download all state files
aws s3 sync s3://terraform-state-prod/ ./state-backup/

# Create versioned backup
aws s3 cp s3://terraform-state-prod/ \
  s3://terraform-state-backup-prod/ \
  --recursive \
  --source-region us-east-2 \
  --region us-west-2
```

#### Restore from Version

```bash
# List versions
aws s3api list-object-versions \
  --bucket terraform-state-prod \
  --prefix prod/vpc/

# Restore specific version
aws s3api get-object \
  --bucket terraform-state-prod \
  --key prod/vpc/terraform.tfstate \
  --version-id VERSION_ID \
  terraform.tfstate.restored
```

### Cost Considerations

- **S3 Storage**: ~$0.023/GB/month (minimal for state files)
- **S3 Requests**: Negligible for typical Terraform usage
- **DynamoDB**: On-demand pricing, usually <$1/month
- **Total**: Expect $1-5/month for typical usage

---

## elastic_container_registry

### Overview

Creates an ECR repository for Docker container images with security best practices including immutable tags and automatic vulnerability scanning.

### Usage Example

```hcl
module "app_ecr" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/elastic_container_registry?ref=main"

  aws_ecr_repository_name = "my-application"

  tags = {
    Application = "my-app"
    Environment = "production"
  }
}
```

### Features

- **Immutable Tags**: Prevents tag overwriting
- **Scan on Push**: Automatic vulnerability scanning
- **Lifecycle Policies**: (Add separately for cost optimization)

---

## Best Practices

### Bootstrap Terraform Module

1. **Run First**: Deploy bootstrap before any other infrastructure
2. **Separate State**: Keep bootstrap state separate from application state
3. **Backup**: Regularly backup S3 state bucket to different region
4. **Access Control**: Restrict state bucket access to service role only
5. **Documentation**: Document state key naming conventions

### State Management

1. **Key Organization**: Use consistent directory structure
2. **Workspaces**: Consider Terraform workspaces for environments
3. **State Locking**: Never disable state locking
4. **Regular Backups**: Automate state file backups
5. **Version Control**: Never commit state files to Git

### ECR

1. **Tagging Strategy**: Use semantic versioning (v1.2.3)
2. **Immutable Tags**: Enabled by default, don't override
3. **Scan Findings**: Review and address vulnerabilities
4. **Lifecycle Policies**: Implement to remove old images

### General

- Test bootstrap process in dev account first
- Document recovery procedures
- Monitor state bucket for unauthorized access
- Implement least-privilege IAM policies
- Regular security audits
