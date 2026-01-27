# Terraform Modules Testing Guide

This guide explains how to test Terraform modules in this repository. Currently, two modules have comprehensive test suites: `vpc_module` and `ec2_scalable`.

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Test Types](#test-types)
4. [Running Tests](#running-tests)
5. [Tested Modules](#tested-modules)
6. [Writing Tests](#writing-tests)
7. [Troubleshooting](#troubleshooting)

---

## Overview

Testing ensures modules work correctly and prevents regressions. We use [Terratest](https://terratest.gruntwork.io/), a Go testing framework designed for infrastructure code.

### Test Framework

- **Language**: Go 1.21+
- **Framework**: Terratest
- **Test Types**: Unit tests (fast, no AWS) and Integration tests (creates real resources)
- **CI/CD**: Automated via GitHub Actions

---

## Prerequisites

### Required Tools

| Tool | Version | Purpose |
|------|---------|---------|
| Go | 1.21+ | Test execution |
| Terraform | 1.6+ | Infrastructure validation |
| AWS CLI | 2.x | AWS credential management |

### Installation

**macOS:**
```bash
# Install Go
brew install go

# Install Terraform
brew install terraform

# Install AWS CLI
brew install awscli

# Verify installations
go version
terraform version
aws --version
```

**Linux:**
```bash
# Go
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin

# Terraform
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip
unzip terraform_1.6.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

### AWS Credentials

Integration tests require AWS credentials. Configure via AWS SSO or access keys:

```bash
# Option 1: AWS SSO (recommended)
aws configure sso

# Option 2: Access keys
aws configure --profile infra-sandbox
```

---

## Test Types

### Unit Tests

**Characteristics:**
- ✅ Fast (seconds)
- ✅ No AWS resources created
- ✅ No AWS credentials required
- ✅ Validates Terraform syntax and logic
- ✅ Safe to run anytime

**What They Test:**
- Terraform plan generation
- Variable validation
- Resource configuration
- Module dependencies

**When to Run:**
- Before committing code
- During development
- In CI/CD pipelines

### Integration Tests

**Characteristics:**
- ⚠️ Slower (minutes)
- ⚠️ Creates real AWS resources
- ⚠️ Requires AWS credentials
- ⚠️ Incurs AWS costs (minimal)
- ✅ Validates actual resource creation

**What They Test:**
- Resource creation
- Resource configuration
- Resource destruction
- AWS API interactions

**When to Run:**
- Before merging to main
- For critical changes
- Before releases

---

## Running Tests

### Using the Test Runner Script

The repository includes `run-tests.sh` for easy test execution:

#### Run Unit Tests Only (Fast)

```bash
./run-tests.sh unit
```

**Output:**
```
ℹ️  Terraform Modules Test Runner
ℹ️  Checking dependencies...
✅ Dependencies check passed
ℹ️  Setting up test environment...
✅ Test environment setup complete
ℹ️  Discovering test modules...
  - ec2_scalable
  - vpc_module
ℹ️  Running unit tests for ec2_scalable...
✅ Unit tests passed for ec2_scalable
ℹ️  Running unit tests for vpc_module...
✅ Unit tests passed for vpc_module
```

#### Run Integration Tests (Creates AWS Resources)

```bash
AWS_PROFILE=infra-sandbox ./run-tests.sh integration
```

⚠️ **Warning:** Integration tests create real AWS resources in your account!

#### Run All Tests

```bash
AWS_PROFILE=infra-sandbox ./run-tests.sh all
```

#### Clean Up Test Artifacts

```bash
./run-tests.sh cleanup
```

### Manual Test Execution

#### Run Unit Tests Manually

```bash
cd test

# All unit tests
go test -v -tags=unit ./... -timeout 10m

# Specific module
go test -v -tags=unit ./vpc_module/... -timeout 10m

# Specific test
go test -v -tags=unit ./vpc_module/... -run TestCustomSubnetSpacing -timeout 10m
```

#### Run Integration Tests Manually

```bash
cd test

# Set AWS credentials
export AWS_PROFILE=infra-sandbox

# All integration tests
go test -v -tags=integration ./... -timeout 30m

# Specific module
go test -v -tags=integration ./ec2_scalable/... -timeout 30m
```

### Test Options

| Flag | Purpose | Example |
|------|---------|---------|
| `-v` | Verbose output | `go test -v` |
| `-tags=unit` | Run only unit tests | `go test -tags=unit` |
| `-tags=integration` | Run only integration tests | `go test -tags=integration` |
| `-timeout` | Set test timeout | `go test -timeout 30m` |
| `-run` | Run specific test | `go test -run TestVPCCreation` |
| `-count=1` | Disable test cache | `go test -count=1` |

---

## Tested Modules

### 1. vpc_module

**Test Location:** `test/vpc_module/`

**Test Files:**
- `vpc_unit_test.go` - Unit tests for VPC configuration
- `vpc_integration_test.go` - Integration tests for VPC creation

#### Unit Tests

Tests VPC configuration without creating resources:

```bash
./run-tests.sh unit
```

**Tests:**
- ✅ Custom subnet spacing validation
- ✅ Security group configuration
- ✅ Public/private subnet logic
- ✅ RDS subnet configuration
- ✅ NAT gateway configuration

#### Integration Tests

Creates actual VPC in AWS and validates:

```bash
AWS_PROFILE=infra-sandbox ./run-tests.sh integration
```

**Tests:**
- ✅ VPC creation with specified CIDR
- ✅ Subnet creation across availability zones
- ✅ Internet Gateway attachment
- ✅ NAT Gateway creation
- ✅ Route table configuration
- ✅ Security group creation
- ✅ VPC flow logs
- ✅ Resource tagging
- ✅ Resource cleanup (destroy)

**Resources Created:**
- VPC
- Subnets (public, private, RDS)
- Internet Gateway
- NAT Gateways
- Elastic IPs
- Route Tables
- Security Groups
- VPC Flow Logs

**Cost:** ~$0.10 per test run (mostly NAT Gateway)

**Duration:** ~5-10 minutes

#### Example Unit Test

```go
func TestCustomSubnetSpacing(t *testing.T) {
    options := &terraform.Options{
        TerraformDir: "./fixtures/main",
        Vars: map[string]interface{}{
            "vpc_cidr": "10.1.0.0/16",
            "custom_subnets": []map[string]interface{}{
                {"name": "app", "public": false, "subnet_count": 3},
                {"name": "data", "public": false, "subnet_count": 3},
            },
        },
    }

    _, err := terraform.InitAndPlanAndShowE(t, options)
    require.NoError(t, err)
}
```

#### Example Integration Test

```go
func TestVPCCreation(t *testing.T) {
    options := &terraform.Options{
        TerraformDir: "./fixtures/main",
        Vars: map[string]interface{}{
            "vpc_cidr": "10.1.0.0/16",
            "region": "us-east-1",
        },
    }

    defer terraform.Destroy(t, options)

    terraform.InitAndApply(t, options)

    vpcID := terraform.Output(t, options, "vpc_id")
    require.NotEmpty(t, vpcID)
}
```

### 2. ec2_scalable

**Test Location:** `test/ec2_scalable/`

**Test Files:**
- `ec2_unit_test.go` - Unit tests for EC2 configuration
- `ec2_integration_test.go` - Integration tests for EC2 deployment

#### Unit Tests

Tests EC2 instance configuration:

```bash
./run-tests.sh unit
```

**Tests:**
- ✅ Instance type validation
- ✅ AMI configuration
- ✅ Security group configuration
- ✅ User data script validation
- ✅ IAM role attachment
- ✅ EBS volume configuration
- ✅ Scaling configuration

#### Integration Tests

Creates actual EC2 instances and validates:

```bash
AWS_PROFILE=infra-sandbox ./run-tests.sh integration
```

**Tests:**
- ✅ EC2 instance creation
- ✅ Instance accessibility via SSM
- ✅ Security group rules
- ✅ IAM role attachment
- ✅ EBS volume attachment
- ✅ User data execution
- ✅ Tags and naming
- ✅ Resource cleanup

**Resources Created:**
- EC2 instance
- Security group
- IAM role
- IAM instance profile
- EBS volumes
- SSM association

**Cost:** ~$0.05 per test run

**Duration:** ~3-5 minutes

#### Test Fixtures

Both modules use test fixtures in `fixtures/` directories:

```
test/vpc_module/fixtures/
└── main/
    ├── main.tf          # Calls the module
    ├── variables.tf     # Test input variables
    └── outputs.tf       # Test outputs

test/ec2_scalable/fixtures/
└── main/
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

**Example Fixture (`fixtures/main/main.tf`):**

```hcl
module "vpc_test" {
  source = "../../../../modules/vpc_module"

  vpc_cidr                 = var.vpc_cidr
  region                   = var.region
  create_internet_gateway  = var.create_internet_gateway
  create_nat_gateway       = var.create_nat_gateway
  custom_subnets          = var.custom_subnets
}

output "vpc_id" {
  value = module.vpc_test.vpc_id
}
```

---

## Writing Tests

### Adding Tests to a New Module

1. **Create test directory:**

```bash
mkdir -p test/my-module/fixtures/main
```

2. **Create test fixture:**

```hcl
# test/my-module/fixtures/main/main.tf
module "test" {
  source = "../../../../modules/my-module"

  # Pass test variables
  name = var.name
}

output "resource_id" {
  value = module.test.resource_id
}
```

3. **Create unit test:**

```go
//go:build unit
// +build unit

package my_module_test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

func TestModulePlan(t *testing.T) {
    options := &terraform.Options{
        TerraformDir: "./fixtures/main",
        Vars: map[string]interface{}{
            "name": "test-resource",
        },
    }

    _, err := terraform.InitAndPlanAndShowE(t, options)
    require.NoError(t, err)
}
```

4. **Create integration test:**

```go
//go:build integration
// +build integration

package my_module_test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

func TestModuleCreation(t *testing.T) {
    options := &terraform.Options{
        TerraformDir: "./fixtures/main",
        Vars: map[string]interface{}{
            "name": "test-resource",
        },
    }

    defer terraform.Destroy(t, options)

    terraform.InitAndApply(t, options)

    resourceID := terraform.Output(t, options, "resource_id")
    require.NotEmpty(t, resourceID)
}
```

5. **Update `go.mod`:**

```bash
cd test
go mod tidy
```

6. **Run tests:**

```bash
./run-tests.sh unit
AWS_PROFILE=infra-sandbox ./run-tests.sh integration
```

### Best Practices

1. **Always use build tags:**
   ```go
   //go:build unit
   //go:build integration
   ```

2. **Always defer destroy in integration tests:**
   ```go
   defer terraform.Destroy(t, options)
   ```

3. **Use descriptive test names:**
   ```go
   func TestVPCCreatesNATGatewayInEachAZ(t *testing.T)
   ```

4. **Test both success and failure cases:**
   ```go
   func TestInvalidCIDRFails(t *testing.T)
   ```

5. **Use fixtures for reusable test infrastructure:**
   - Keep fixtures simple
   - One fixture per test scenario
   - Use variables for flexibility

6. **Keep tests fast:**
   - Unit tests should complete in seconds
   - Integration tests should complete in minutes
   - Use parallel execution where possible

---

## Troubleshooting

### Test Failures

#### "Module not found"

**Problem:** Go can't find test dependencies

**Solution:**
```bash
cd test
go mod download
go mod tidy
```

#### "AWS credentials not configured"

**Problem:** Integration tests can't authenticate to AWS

**Solution:**
```bash
# Set AWS profile
export AWS_PROFILE=infra-sandbox

# Or use access keys
export AWS_ACCESS_KEY_ID=xxx
export AWS_SECRET_ACCESS_KEY=xxx

# Verify
aws sts get-caller-identity
```

#### "Timeout exceeded"

**Problem:** Test took too long

**Solution:**
```bash
# Increase timeout
go test -v -tags=integration ./... -timeout 60m
```

#### "Resources not cleaned up"

**Problem:** Test failed before destroying resources

**Solution:**
```bash
# Manually destroy
cd test/vpc_module/fixtures/main
terraform destroy

# Or use AWS console to find and delete resources with tag:
# test_resource_tag = "terratest-vpc-*"
```

### Common Issues

#### Issue: "Plan failed: Invalid CIDR block"

**Cause:** Test fixture has invalid CIDR configuration

**Fix:** Check `fixtures/main/main.tf` and ensure valid CIDR blocks

#### Issue: "Resource limit exceeded"

**Cause:** AWS account limits (VPCs, EIPs, etc.)

**Fix:**
- Run tests in different AWS account
- Clean up unused resources
- Request limit increases

#### Issue: "Test cache causing false positives"

**Cause:** Go is caching test results

**Fix:**
```bash
go clean -testcache
go test -count=1 -v -tags=unit ./...
```

### Getting Help

1. Check test output for specific errors
2. Review CloudWatch Logs for AWS resource creation
3. Check Terraform state in test fixtures
4. Review [Terratest documentation](https://terratest.gruntwork.io/docs/)
5. Contact infrastructure team

---

## CI/CD Integration

Tests run automatically in GitHub Actions on:
- Pull requests
- Merges to main
- Tagged releases

### GitHub Actions Configuration

See `..github/workflows`:

```yaml
test:unit:
  stage: test
  script:
    - ./run-tests.sh unit

test:integration:
  stage: test
  only:
    - main
  script:
    - ./run-tests.sh integration
  when: manual  # Requires manual trigger
```

---

## Next Steps

- Add tests for more modules
- Implement performance benchmarking
- Add security scanning tests
- Create test coverage reports

**For module-specific testing details, see:**
- [vpc_module README](../modules/vpc_module/README.md)
- [ec2_scalable README](../modules/ec2_scalable/README.md)

**Related Documentation:**
- [Module Development Guide](./MODULE_DEVELOPMENT.md)
- [Main README](../README.md)
