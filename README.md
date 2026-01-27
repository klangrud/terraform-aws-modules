# Terraform Modules

A centralized repository of reusable, production-ready Terraform modules for AWS infrastructure provisioning. These modules implement security best practices, compliance requirements, and organizational standards.

## Overview

This repository contains 13 Terraform modules covering:
- **Networking**: VPC configuration with multi-tier architecture
- **Compute**: EC2 and ECS container orchestration
- **Storage**: S3 buckets with versioning and replication capabilities
- **Security & Compliance**: IAM policies, identity providers, SFTP credentials
- **Monitoring**: CloudWatch alarms, SNS notifications, and flow logs
- **Foundation**: Bootstrap infrastructure for Terraform state management

## Quick Start

### Using a Module

Reference modules via Git source in your Terraform configuration:

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name   = "my-vpc"
  region = "us-east-2"
  vpc_cidr = "10.0.0.0/16"
  # ... additional configuration
}
```

### Module Categories

- **[Networking & Infrastructure](./docs/NETWORKING.md)** - VPC, subnets, gateways, endpoints
- **[Compute & Containers](./docs/COMPUTE.md)** - EC2, ECS task definitions
- **[Storage & Data](./docs/STORAGE.md)** - S3 buckets, replication
- **[Security & Access](./docs/SECURITY.md)** - IAM policies, identity providers, SFTP
- **[Monitoring & Alerts](./docs/MONITORING.md)** - CloudWatch alarms, SNS topics
- **[Bootstrap & Foundation](./docs/BOOTSTRAP.md)** - Terraform state management

## Versioning and Releases

This repository follows [Semantic Versioning 2.0.0](https://semver.org/) and uses [Conventional Commits](https://www.conventionalcommits.org/) for automated release management.

### Semantic Versioning

- **MAJOR** (v1.0.0 → v2.0.0): Breaking changes that require action
- **MINOR** (v1.0.0 → v1.1.0): New features, backward compatible
- **PATCH** (v1.0.0 → v1.0.1): Bug fixes, backward compatible

### Module Pinning

Pin modules to specific versions for production stability:

```hcl
# Recommended: Pin to specific version
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.2.3"
  # ...
}

# Not recommended for production: Use main branch
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"
  # ...
}
```

### Automated Release Process

1. **Commit**: All commits must follow [Conventional Commits](https://www.conventionalcommits.org/) format
2. **Merge**: When merged to main, a version tag is automatically created based on commit types
3. **Release**: Maintainers manually trigger release creation via GitHub Actions
4. **Changelog**: [CHANGELOG.md](./CHANGELOG.md) is automatically generated from commit history

### Contributing

See [CONTRIBUTING.md](./CONTRIBUTING.md) for commit message format, development workflow, and module development guidelines.

### Viewing Releases

- **Releases**: [GitHub Releases](https://github.com/klangrud/terraform-aws-modules/releases)
- **Tags**: [Git Tags](https://github.com/klangrud/terraform-aws-modules/tags)
- **Changelog**: [CHANGELOG.md](./CHANGELOG.md)

## Available Modules

| Module | Purpose | Use Case |
|--------|---------|----------|
| [vpc_module](./modules/vpc_module) | Comprehensive VPC with multi-tier architecture | Foundation for all AWS applications |
| [ec2_scalable](./modules/ec2_scalable) | Scalable EC2 instances with EBS management | Application clusters, standalone applications |
| [ec2_user_data](./modules/ec2_user_data) | Standard EC2 user data scripts | EC2 initialization |
| [container_automation_ecs](./modules/container_automation_ecs) | ECS task definitions with ECR automation | Containerized applications |
| [elastic_container_registry](./modules/elastic_container_registry) | ECR repository | Container image storage |
| [ecs_monitoring](./modules/ecs_monitoring) | CloudWatch alarms for ECS services | ECS service monitoring |
| [s3_bucket](./modules/s3_bucket) | Secure S3 bucket with logging | General-purpose storage |
| [s3_bucket_replication](./modules/s3_bucket_replication) | S3 cross-account replication | Data replication between accounts |
| [alerts_sns_topic](./modules/alerts_sns_topic) | SNS topic for alerts | Email notifications |
| [identity_provider](./modules/identity_provider) | SAML identity provider integration | SSO authentication |
| [iam_password_policy](./modules/iam_password_policy) | Account-wide password policy | Password compliance |
| [transfer_family_sftp_secret](./modules/transfer_family_sftp_secret) | SFTP credentials in Secrets Manager | Credential management |
| [bootstrap_terraform](./modules/bootstrap_terraform) | Terraform state backend | New AWS account setup |

## Architecture Patterns

### Multi-Tier Application Architecture

```
┌─────────────────────────────────────────────────────────┐
│ VPC (vpc_module)                                        │
│                                                         │
│  ┌─────────────────┐      ┌─────────────────┐          │
│  │ Public Subnet   │      │ Private Subnet  │          │
│  │                 │      │                 │          │
│  │ ┌─────────────┐ │      │ ┌─────────────┐ │          │
│  │ │ NAT Gateway │ │      │ │ ECS Service │ │          │
│  │ └─────────────┘ │      │ │ (container- │ │          │
│  │                 │      │ │  automation)│ │          │
│  │ ┌─────────────┐ │      │ └─────────────┘ │          │
│  │ │ Internet GW │ │      │                 │          │
│  │ └─────────────┘ │      │ ┌─────────────┐ │          │
│  └─────────────────┘      │ │ EC2 Instance│ │          │
│                           │ │ (ec2_       │ │          │
│                           │ │  scalable)  │ │          │
│  ┌─────────────────┐      │ └─────────────┘ │          │
│  │ RDS Subnet      │      │                 │          │
│  │                 │      └─────────────────┘          │
│  │ ┌─────────────┐ │                                   │
│  │ │ Database    │ │                                   │
│  │ └─────────────┘ │                                   │
│  └─────────────────┘                                   │
└─────────────────────────────────────────────────────────┘
```

### Cross-Account Replication Architecture

```
┌──────────────────────────────────────┐
│ Source Account                       │
│                                      │
│  ┌─────────────────────────┐         │
│  │ Source S3 Bucket        │         │
│  │ (s3_bucket)             │         │
│  │                          │         │
│  │ • Versioning enabled    │         │
│  │ • Encryption at rest    │         │
│  │ • Access logging        │         │
│  └────────────┬─────────────┘         │
└───────────────┼──────────────────────┘
                │ Cross-Account
                │ Replication
                │ (s3_bucket_replication)
                ▼
┌──────────────────────────────────────┐
│ Destination Account                  │
│                                      │
│  ┌─────────────────────────┐         │
│  │ Destination S3 Bucket   │         │
│  │                          │         │
│  │ • Versioning enabled    │         │
│  │ • Encryption at rest    │         │
│  │ • Read-only access      │         │
│  └──────────────────────────┘         │
└──────────────────────────────────────┘
```

## Key Features

### Security Best Practices
- Encryption at rest (S3, EBS, Secrets Manager)
- Private subnet architecture with NAT gateway
- Least-privilege IAM policies
- VPC endpoints for AWS service access
- Security group management
- Access logging and audit trails

### Compliance
- Secrets Manager for credential management
- Password policy enforcement
- SAML-based SSO support

### High Availability & DR
- Multi-AZ subnet distribution
- Cross-account replication
- S3 versioning
- ECS Fargate for auto-scaling

### Monitoring & Operations
- CloudWatch alarms for critical metrics
- SNS notifications for alerts
- VPC flow logs
- SSM Session Manager access
- Detailed monitoring options

## Development

### Prerequisites
- Terraform 1.6.6+
- Go (for testing)
- AWS CLI configured
- GitHub access for CI/CD

### Testing

Run module tests:
```bash
# Unit tests
./run-tests.sh unit

# Integration tests (requires AWS credentials)
./run-tests.sh integration

# Cleanup test resources
./run-tests.sh cleanup
```

### CI/CD Pipeline

The repository uses GitHub Actions with the following stages:

1. **Lint** - Terraform fmt checks and module change detection
2. **Validate** - Terraform validation for all modules
3. **Unit** - Go-based unit tests
4. **Integration** - Real AWS infrastructure tests
5. **Cleanup** - Automated cleanup of test resources

### Code Quality Tools

- **terraform fmt** - Code formatting
- **terraform validate** - Configuration validation
- **tflint** - Linting with `.tflint.hcl` configuration
- **pre-commit hooks** - Automated checks before commit

### Adding a New Module

1. Create module directory under `modules/`
2. Add required files: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
3. Create `README.md` using terraform-docs format
4. Add tests in `test/` directory
5. Update this documentation
6. Submit merge request

## Module Documentation

Each module includes:
- **Purpose** - What the module does and why
- **Resources** - AWS resources created
- **Variables** - Configuration inputs with types and defaults
- **Outputs** - Values exported for use by other modules
- **Examples** - Common usage patterns
- **Dependencies** - Requirements and related modules

See individual module directories for detailed README files.

## Common Usage Patterns

### Pattern 1: New Application Infrastructure

```hcl
# 1. Create VPC
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"
  name   = "app-vpc"
  region = "us-east-2"
  vpc_cidr = "10.0.0.0/16"
  create_rds_subnets = true
}

# 2. Create ECS task definition
module "app_task" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/container_automation_ecs?ref=main"
  aws_ecr_image_repository_name = "my-app"
  family = "my-app-task"
  cpu    = "256"
  memory = "512"
}

# 3. Set up monitoring
module "monitoring" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ecs_monitoring?ref=main"
  ecs_cluster_name = "my-cluster"
  ecs_service_name = "my-app"
  sns_subscriptions = ["alerts@example.com"]
}
```

### Pattern 2: S3 with Cross-Account Replication

```hcl
# Source bucket in primary account
module "source_bucket" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=main"

  bucket_name = "my-data-bucket"
  versioning  = true
}

# Replication to destination account
module "replication" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket_replication?ref=main"

  source_bucket_arn      = module.source_bucket.bucket_arn
  destination_bucket_arn = "arn:aws:s3:::destination-bucket"
  destination_account_id = "123456789012"
}
```

### Pattern 3: Bootstrap New AWS Account

```hcl
module "bootstrap" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/bootstrap_terraform?ref=main"

  s3_bucket_name       = "terraform-state-prod"
  dynamodb_table_name  = "terraform-locks-prod"
  aws_account_id       = "123456789012"
}

# Configure backend after bootstrap
terraform {
  backend "s3" {
    bucket         = "terraform-state-prod"
    key            = "prod/terraform.tfstate"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks-prod"
    encrypt        = true
  }
}
```

## Support and Contribution

### Getting Help
- Check module README files for detailed documentation
- Review test fixtures in `test/` directories for examples

### Contributing
- Follow existing module patterns and structure
- Include comprehensive documentation
- Add tests for new functionality
- Ensure all CI/CD checks pass

### Standards
- All modules must include README with terraform-docs format
- Variables must have descriptions and types
- Outputs must have descriptions
- Tags are required for trackable resources
- Security best practices are mandatory

## Version Compatibility

- **Terraform**: >= 1.6.6
- **AWS Provider**: >= 3.0 (varies by module)
- **Go**: Latest stable (for tests)

## License

Open source Terraform modules for AWS infrastructure.

## Additional Resources

- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.
<!-- END_TF_DOCS -->
