# Terraform Modules - Module Library

---

## Overview

A centralized Terraform module library provides production-ready, tested, and documented infrastructure modules for AWS. All modules follow best practices for security, scalability, and maintainability.

**Key Benefits:**
- ✅ Production-tested modules with comprehensive test suites
- ✅ Consistent security baselines (encryption, IAM, monitoring)
- ✅ Complete documentation with usage examples
- ✅ Version-controlled and git-tagged releases
- ✅ HIPAA compliance support

---

## 📚 Documentation

Comprehensive documentation is available in our GitHub repository:

**Repository:** `https://github.com/klangrud/terraform-aws-modules`

### Core Documentation

| Document | Description | Link |
|----------|-------------|------|
| **Main README** | Start here - repository overview and module index | [README.md](https://github.com/klangrud/terraform-aws-modules/blob/main/README.md) |
| **Module Testing Guide** | How to test modules locally and in CI/CD | [TESTING.md](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md) |
| **Module Development Guide** | Standards and best practices for creating new modules | [MODULE_DEVELOPMENT.md](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/MODULE_DEVELOPMENT.md) |

### Module-Specific Documentation

| Module | Description | Documentation |
|--------|-------------|---------------|
| **vpc_module** | Multi-tier VPC with flexible subnet configuration | [README.md](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/vpc_module/README.md) |
| **ec2_scalable** | Scalable EC2 instances with auto-mounting EBS volumes | [README.md](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/ec2_scalable/README.md) |
| **s3_bucket** | S3 bucket with encryption and versioning | Module README |
| **container_automation_ecs** | ECS cluster with Fargate support | Module README |

---

## 🚀 Quick Start

### Using a Module in Your Terraform Project

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.2.3"

  name     = "my-application"
  region   = "us-east-1"
  vpc_cidr = "10.0.0.0/16"

  tags = {
    Environment = "production"
    Project     = "my-project"
  }
}
```

**Important:**
- Always specify a version tag (`?ref=v1.2.3`) for production use
- Never use `main` branch directly in production
- Check the module's README for required and optional variables

**Full Usage Guide:** [Using Modules](https://github.com/klangrud/terraform-aws-modules/blob/main/README.md#using-modules)

---

## 📦 Available Modules

### Networking Modules

| Module | Purpose | Tested |
|--------|---------|--------|
| [**vpc_module**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/vpc_module/README.md) | VPC with public/private/RDS subnets, NAT/IGW, VPC endpoints | ✅ Yes |
| [**ec2_user_data**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/ec2_user_data/) | Cloud-init user data generation for EC2 instances | ⏸️ No |

### Compute Modules

| Module | Purpose | Tested |
|--------|---------|--------|
| [**ec2_scalable**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/ec2_scalable/README.md) | Scalable EC2 instances (1-100) with EBS management | ✅ Yes |
| [**ec2_scalable**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/ec2_scalable/) | Scalable EC2 instances (1-100) with EBS management | ✅ Yes |
| [**container_automation_ecs**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/container_automation_ecs/) | ECS cluster with Fargate and EC2 launch types | ⏸️ No |
| [**ecs_monitoring**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/ecs_monitoring/) | CloudWatch alarms for ECS services | ⏸️ No |

### Storage Modules

| Module | Purpose | Tested |
|--------|---------|--------|
| [**s3_bucket**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/s3_bucket/) | Standard S3 bucket with encryption | ⏸️ No |
| [**s3_bucket_replication**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/s3_bucket_replication/) | Flexible cross-account/region replication with bidirectional support | ✅ Yes |

### Security & IAM Modules

| Module | Purpose | Tested |
|--------|---------|--------|
| [**transfer_family_sftp_secret**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/transfer_family_sftp_secret/) | AWS Secrets Manager integration for SFTP | ⏸️ No |
| [**identity_provider**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/identity_provider/) | IAM SAML/OIDC identity provider setup | ⏸️ No |
| [**iam_password_policy**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/iam_password_policy/) | Account-wide IAM password policy | ⏸️ No |

### Foundation Modules

| Module | Purpose | Tested |
|--------|---------|--------|
| [**bootstrap_terraform**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/bootstrap_terraform/) | Bootstrap new AWS account with state backend | ✅ Yes |
| [**elastic_container_registry**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/elastic_container_registry/) | ECR repository with lifecycle policies | ⏸️ No |
| [**alerts_sns_topic**](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/alerts_sns_topic/) | SNS topic for alerting | ⏸️ No |

---

## 🔍 Common Tasks

### Task 1: Use a Module in Your Project

**Time:** 5 minutes

1. Choose a module from the list above
2. Review the module's README for variables and examples
3. Add the module block to your Terraform code
4. Run `terraform init` to download the module
5. Run `terraform plan` to preview changes

**Example:**

```hcl
module "my_vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.0.0"

  name     = "production-vpc"
  region   = "us-east-1"
  vpc_cidr = "10.0.0.0/16"
}
```

### Task 2: Test a Module Locally

**Time:** 10-15 minutes

**Prerequisites:**
- Go 1.21+
- Terraform 1.6+
- AWS credentials configured

**Steps:**

1. Clone the repository:
   ```bash
   git clone git@github.com:klangrud/terraform-aws-modules.git
   cd terraform-aws-modules
   ```

2. Run tests for a specific module:
   ```bash
   # Unit tests (fast, no AWS resources)
   ./run-tests.sh unit

   # Integration tests (creates real AWS resources)
   export AWS_PROFILE=your-profile
   ./run-tests.sh integration
   ```

**Full Testing Guide:** [TESTING.md](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md)

### Task 3: Create a New Module

**Time:** 1-2 hours (depending on complexity)

**Steps:**

1. Review the module development guide:
   ```bash
   # Read the guide
   cat docs/MODULE_DEVELOPMENT.md
   ```

2. Create module directory and files:
   ```bash
   mkdir -p modules/my-new-module
   cd modules/my-new-module
   touch main.tf variables.tf outputs.tf README.md
   ```

3. Implement the module following standards:
   - Define variables with descriptions
   - Implement resources
   - Define outputs
   - Write comprehensive README

4. Create tests:
   ```bash
   mkdir -p test/my-new-module/fixtures/basic
   # Create unit and integration tests
   ```

5. Test your module:
   ```bash
   ./run-tests.sh unit
   export AWS_PROFILE=dev
   ./run-tests.sh integration
   ```

6. Document in README.md with examples

**Full Development Guide:** [MODULE_DEVELOPMENT.md](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/MODULE_DEVELOPMENT.md)

---

## 🧪 Testing

### Tested Modules

Currently, **3 modules** have comprehensive test suites:

1. **vpc_module**:
   - Unit tests for VPC configuration validation
   - Integration tests creating real VPCs in AWS
   - Test fixtures: basic, custom-subnet, endpoint, RDS subnet, tagging

2. **ec2_scalable**:
   - Unit tests for EC2 instance configuration
   - Integration tests with EBS volume management
   - Test fixtures: basic instance deployment

3. **s3_bucket_replication**:
   - 14 unit tests covering all replication scenarios
   - Integration tests with cross-account and bidirectional replication
   - Test fixtures: basic replication configuration
   - Tests: bucket existence combinations, bidirectional, existing IAM roles, cross-account, prefix filters, per-rule settings

### Test Framework

- **Language**: Go 1.21+
- **Framework**: [Terratest](https://terratest.gruntwork.io/)
- **Test Types**:
  - **Unit Tests**: Fast (seconds), no AWS resources created
  - **Integration Tests**: Slower (minutes), creates real AWS resources

### Running Tests

```bash
# All unit tests (fast)
./run-tests.sh unit

# All integration tests (requires AWS credentials)
export AWS_PROFILE=infra-sandbox
./run-tests.sh integration

# All tests
./run-tests.sh all

# Cleanup test artifacts
./run-tests.sh cleanup
```

**Detailed Testing Documentation:** [TESTING.md](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md)

---

## 📋 Module Usage Best Practices

### 1. Always Use Version Tags

✅ **Good:**
```hcl
source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.2.3"
```

❌ **Bad:**
```hcl
source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module"  # Uses main branch
```

### 2. Review Module README First

Every module has a README with:
- Usage examples
- Input variables
- Output values
- Best practices
- Testing instructions

### 3. Test Locally Before Production

Use the provided test suites to validate configurations:
```bash
./run-tests.sh unit          # Quick validation
./run-tests.sh integration   # Full AWS validation
```

### 4. Follow Security Defaults

Modules use secure defaults:
- Encryption enabled by default
- Public access disabled by default
- IAM permissions follow least-privilege
- Termination protection enabled

### 5. Tag All Resources

Always provide meaningful tags:
```hcl
tags = {
  Environment = "production"
  Project     = "healthcare-platform"
  Owner       = "data-engineering"
  ManagedBy   = "terraform"
}
```

---

## 🛡️ Security & Compliance

### HIPAA Compliance Support

Several modules support HIPAA compliance:

- **s3_bucket**: Encrypted storage with versioning
- **vpc_module**: VPC flow logs for auditing
- **ec2_scalable**: Encrypted EBS volumes, IMDSv2, SSM access
- **transfer_family_sftp_secret**: Secure credential management for SFTP

### Security Features

All modules follow security best practices:
- **Encryption by Default**: All storage encrypted
- **Least Privilege IAM**: Minimal required permissions
- **Network Isolation**: Private by default
- **Audit Logging**: CloudWatch and CloudTrail integration
- **No Hardcoded Secrets**: Use AWS Secrets Manager

---

## 🔧 Module Development

### Creating a New Module

See the comprehensive guide: [MODULE_DEVELOPMENT.md](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/MODULE_DEVELOPMENT.md)

**Key Requirements:**
- Follow standard directory structure
- Comprehensive README with examples
- Unit and integration tests
- Terraform-docs auto-generation
- Secure defaults
- Input validation

### Module Structure

```
modules/
└── my-module/
    ├── README.md          # Module documentation
    ├── main.tf            # Primary resources
    ├── variables.tf       # Input variables
    ├── outputs.tf         # Output values
    ├── locals.tf          # Local values (optional)
    └── data.tf            # Data sources (optional)
```

### Testing Requirements

Every module must have:
- **Unit Tests**: Validate Terraform plans without creating resources
- **Integration Tests**: Create real AWS resources and validate
- **Test Fixtures**: Example usage for testing

---

## 📊 Module Maturity Matrix

| Maturity Level | Criteria |
|----------------|----------|
| 🟢 **Production** | Comprehensive tests, docs, used in prod |
| 🟡 **Beta** | Tests exist, docs complete, not yet in prod |
| 🟠 **Alpha** | Basic docs, no tests, experimental |
| ⚪ **Legacy** | Deprecated, use alternative |

**Current Production Modules:**
- vpc_module 🟢
- ec2_scalable 🟢
- s3_bucket_replication 🟢

---

## 🔗 Quick Links

### Repository Access

- **GitHub Repository**: https://github.com/klangrud/terraform-aws-modules
- **Clone URL**: `git@github.com:klangrud/terraform-aws-modules.git`
- **HTTPS URL**: `https://github.com/klangrud/terraform-aws-modules.git`

### Key Documentation

- [Main README](https://github.com/klangrud/terraform-aws-modules/blob/main/README.md)
- [Testing Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md)
- [Module Development Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/MODULE_DEVELOPMENT.md)
- [VPC Module README](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/vpc_module/README.md)
- [EC2 Scalable Module README](https://github.com/klangrud/terraform-aws-modules/blob/main/modules/ec2_scalable/README.md)

### Related Resources

- [AWS Terraform Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)
- [Terratest Documentation](https://terratest.gruntwork.io/)

---

## 💡 Getting Help

### For Module Usage Questions

1. Check the module's README for usage examples
2. Review the [Testing Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md) for testing examples
3. Look at test fixtures for working examples: `test/<module-name>/fixtures/`
4. Contact the infrastructure team

### For Module Development

1. Read the [Module Development Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/MODULE_DEVELOPMENT.md)
2. Review existing modules: `vpc_module`, `ec2_scalable`
3. Check the [Testing Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md)
4. Contact the infrastructure team

### Support Escalation

1. **Level 1**: Check module README and test fixtures
2. **Level 2**: Review core documentation (TESTING.md, MODULE_DEVELOPMENT.md)
3. **Level 3**: Contact infrastructure team

---

## 🔄 Updates

**Last Updated:** December 16, 2025

**Documentation Version:** 1.1

**Next Review:** June 16, 2026

For the latest documentation, always refer to the GitHub repository: https://github.com/klangrud/terraform-aws-modules

---

## 📌 Quick Tips

> **New to Terraform Modules?** Start with the [Main README](https://github.com/klangrud/terraform-aws-modules/blob/main/README.md)

> **Need to use a module?** Check the module's README for examples and variable documentation

> **Want to test locally?** See the [Testing Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/TESTING.md)

> **Creating a new module?** Follow the [Module Development Guide](https://github.com/klangrud/terraform-aws-modules/blob/main/docs/MODULE_DEVELOPMENT.md)

> **Looking for examples?** Browse the `test/*/fixtures/` directories for working code

---

*This page provides quick access to Terraform module documentation. For comprehensive details, always refer to the documentation repository linked above.*
