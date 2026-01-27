# Module Development Guide

This guide provides best practices and standards for developing new Terraform modules in this repository.

## Table of Contents

1. [Module Structure](#module-structure)
2. [Creating a New Module](#creating-a-new-module)
3. [Module Design Principles](#module-design-principles)
4. [Variable Standards](#variable-standards)
5. [Output Standards](#output-standards)
6. [Testing Requirements](#testing-requirements)
7. [Documentation Requirements](#documentation-requirements)
8. [Code Style](#code-style)
9. [Examples](#examples)

---

## Module Structure

Every module should follow this standardized directory structure:

```
modules/
└── my-module/
    ├── README.md              # Module documentation
    ├── main.tf                # Primary resource definitions
    ├── variables.tf           # Input variables
    ├── outputs.tf             # Output values
    ├── locals.tf              # Local values (optional)
    ├── data.tf                # Data sources (optional)
    ├── versions.tf            # Provider version constraints (optional)
    └── *.tf                   # Additional resource files (as needed)
```

### File Organization

- **main.tf**: Core resource definitions and primary logic
- **variables.tf**: All input variable declarations
- **outputs.tf**: All output value declarations
- **locals.tf**: Local value computations and transformations
- **data.tf**: Data source lookups
- **Additional .tf files**: Organize by resource type (e.g., `iam.tf`, `security_groups.tf`, `network.tf`)

**Naming Convention**: Use lowercase with hyphens for module directories (e.g., `vpc_module`, `s3-bucket`). Use underscores for multi-word modules (e.g., `ec2_scalable`, `ecs_cluster`).

---

## Creating a New Module

### Step 1: Create Module Directory

```bash
mkdir -p modules/my-new-module
cd modules/my-new-module
```

### Step 2: Create Core Files

Create the essential files:

```bash
touch README.md main.tf variables.tf outputs.tf
```

### Step 3: Define Variables

Start with required variables in `variables.tf`:

```hcl
############################################
# Required Variables
############################################

variable "name" {
  description = "Name of the resource"
  type        = string
}

variable "environment" {
  description = "Environment (dev, uat, prod)"
  type        = string
}

############################################
# Optional Variables
############################################

variable "tags" {
  description = "AWS tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "enable_feature_x" {
  description = "Enable feature X"
  type        = bool
  default     = false
}
```

### Step 4: Implement Resources

Define resources in `main.tf`:

```hcl
locals {
  common_tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_example_resource" "this" {
  name = var.name

  # Resource configuration
  enabled = var.enable_feature_x

  tags = local.common_tags
}
```

### Step 5: Define Outputs

Add outputs in `outputs.tf`:

```hcl
output "resource_id" {
  description = "ID of the created resource"
  value       = aws_example_resource.this.id
}

output "resource_arn" {
  description = "ARN of the created resource"
  value       = aws_example_resource.this.arn
}
```

### Step 6: Write Tests

Create test directory and files:

```bash
mkdir -p test/my-new-module/fixtures/basic
```

See [Testing Requirements](#testing-requirements) for details.

### Step 7: Document the Module

Write comprehensive README.md (see [Documentation Requirements](#documentation-requirements)).

---

## Module Design Principles

### 1. Single Responsibility

Each module should have one clear purpose:

✅ **Good**: `vpc_module` creates VPCs and related networking resources
❌ **Bad**: `infrastructure-module` creates VPCs, ECS clusters, and RDS databases

### 2. Composability

Modules should work well together:

```hcl
# Good: Modules can be composed
module "vpc" {
  source = "../../modules/vpc_module"
  # ...
}

module "ec2" {
  source = "../../modules/ec2_scalable"
  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnet_ids
  # ...
}
```

### 3. Sensible Defaults

Provide secure, production-ready defaults:

```hcl
variable "encryption_enabled" {
  description = "Enable encryption"
  type        = bool
  default     = true  # Secure by default
}

variable "public_access" {
  description = "Allow public access"
  type        = bool
  default     = false  # Secure by default
}
```

### 4. Flexibility

Allow customization for different use cases:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3a.medium"  # Cost-effective default
}

variable "custom_policy_arns" {
  description = "Additional IAM policies to attach"
  type        = list(string)
  default     = []  # Optional customization
}
```

### 5. Fail Fast

Use validation to catch errors early:

```hcl
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 100
    error_message = "instance_count must be between 1 and 100."
  }
}

variable "environment" {
  description = "Environment name"
  type        = string

  validation {
    condition     = contains(["dev", "uat", "prod"], var.environment)
    error_message = "environment must be dev, uat, or prod."
  }
}
```

---

## Variable Standards

### Naming Conventions

- **Use snake_case**: `subnet_ids`, `enable_monitoring`, `custom_tags`
- **Be descriptive**: Avoid abbreviations unless universally understood
- **Prefix booleans**: `enable_`, `create_`, `allow_`, `disable_`
- **Use plurals for lists**: `subnet_ids`, `security_group_ids`, `tags`

### Required vs Optional

Clearly separate required and optional variables:

```hcl
############################################
# Required Variables
############################################

variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
}

############################################
# Optional Variables
############################################

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}
```

### Variable Documentation

Always provide:

1. **Description**: Clear explanation of the variable's purpose
2. **Type**: Explicit type constraint
3. **Default**: Default value for optional variables
4. **Validation**: Input validation where applicable

```hcl
variable "subnet_ids" {
  description = "List of subnet IDs for EC2 placement. Instances will be distributed across subnets for high availability."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}
```

### Complex Types

Use object types for structured configuration:

```hcl
variable "additional_ebs_volumes" {
  description = "List of additional EBS volumes to create and mount"
  type = list(object({
    device_name = string
    mount_point = string
    volume_size = number
    volume_type = optional(string, "gp3")
    iops        = optional(number, 3000)
    encrypted   = optional(bool, true)
  }))
  default = []
}
```

---

## Output Standards

### Naming Conventions

- **Use snake_case**: `vpc_id`, `subnet_ids`, `security_group_arn`
- **Match resource attribute names**: If AWS uses `id`, output should be `resource_id`
- **Use descriptive names**: `private_subnet_ids` instead of `subnets`

### Output Documentation

Always include descriptions:

```hcl
output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.this.id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs across all availability zones"
  value       = [for subnet in aws_subnet.private : subnet.id]
}
```

### Common Output Patterns

```hcl
# Single resource ID
output "resource_id" {
  description = "ID of the resource"
  value       = aws_resource.this.id
}

# Multiple resource IDs
output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.this[*].id
}

# Conditional output
output "nat_gateway_id" {
  description = "NAT Gateway ID (if created)"
  value       = var.create_nat_gateway ? aws_nat_gateway.this[0].id : null
}

# Map output
output "custom_subnets_by_name" {
  description = "Map of custom subnet names to their IDs"
  value = {
    for k, v in aws_subnet.custom : v.tags["Name"] => v.id
  }
}
```

---

## Testing Requirements

Every module must have:

1. **Unit Tests**: Fast tests that validate Terraform plans without creating resources
2. **Integration Tests**: Tests that create real AWS resources and validate functionality

### Test Structure

```
test/
└── my-module/
    ├── fixtures/
    │   └── basic/
    │       ├── main.tf
    │       ├── variables.tf
    │       └── outputs.tf
    ├── my_module_unit_test.go
    └── my_module_integration_test.go
```

### Unit Test Example

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
        TerraformDir: "./fixtures/basic",
        Vars: map[string]interface{}{
            "name":        "test-resource",
            "environment": "dev",
        },
    }

    _, err := terraform.InitAndPlanAndShowE(t, options)
    require.NoError(t, err, "Terraform plan should succeed")
}
```

### Integration Test Example

```go
//go:build integration
// +build integration

package my_module_test

import (
    "testing"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

func TestResourceCreation(t *testing.T) {
    options := &terraform.Options{
        TerraformDir: "./fixtures/basic",
        Vars: map[string]interface{}{
            "name":        "test-resource",
            "environment": "dev",
        },
    }

    defer terraform.Destroy(t, options)

    terraform.InitAndApply(t, options)

    resourceID := terraform.Output(t, options, "resource_id")
    require.NotEmpty(t, resourceID, "Resource ID should be set")
}
```

### Test Fixture

```hcl
# test/my-module/fixtures/basic/main.tf
module "test" {
  source = "../../../../modules/my-module"

  name        = var.name
  environment = var.environment
}

output "resource_id" {
  value = module.test.resource_id
}
```

### Running Tests

Use the provided test runner:

```bash
# Unit tests only
./run-tests.sh unit

# Integration tests
export AWS_PROFILE=your-profile
./run-tests.sh integration
```

See [TESTING.md](./TESTING.md) for comprehensive testing documentation.

---

## Documentation Requirements

Every module must have a comprehensive README.md:

### Required Sections

1. **Title and Description**: Clear module purpose
2. **Features**: Key capabilities
3. **Usage Examples**: At least 3 examples showing different use cases
4. **Input Variables**: Table with all variables
5. **Outputs**: Table with all outputs
6. **Local Testing**: Instructions for testing the module
7. **Best Practices**: Recommendations for using the module

### README Template

````markdown
# Module Name

Brief description of what this module does.

## Features

- Feature 1
- Feature 2
- Feature 3

## Usage Examples

### Basic Usage

```hcl
module "example" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/my-module?ref=v1.0.0"

  name = "my-resource"
  # ...
}
```

### Advanced Usage

```hcl
module "example_advanced" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/my-module?ref=v1.0.0"

  name = "my-resource"
  enable_advanced_features = true
  # ...
}
```

## Input Variables

[Variables documentation]

## Outputs

[Outputs documentation]

## Local Testing

[Testing instructions]

## Best Practices

1. Recommendation 1
2. Recommendation 2

## Related Documentation

- [Testing Guide](../../docs/TESTING.md)
- [Module Development Guide](../../docs/MODULE_DEVELOPMENT.md)
````

### terraform-docs Integration

Use terraform-docs to auto-generate variable and output tables:

```bash
terraform-docs markdown table modules/my-module >> modules/my-module/README.md
```

Wrap auto-generated content in markers:

```markdown
<!-- BEGIN_TF_DOCS -->
[Auto-generated content here]
<!-- END_TF_DOCS -->
```

---

## Code Style

### Formatting

- Use `terraform fmt` to format all files
- 2-space indentation
- Blank line between resource blocks
- Group related resources together

### Commenting

```hcl
############################################
# Section Header
############################################

# Resource-level comment explaining why this exists
resource "aws_example" "this" {
  # Inline comment for complex logic
  count = var.enable_feature ? 1 : 0

  name = var.name
}
```

### Locals Best Practices

Use locals for:
- Repeated computations
- Complex transformations
- Conditional logic
- Tag merging

```hcl
locals {
  # Common tags applied to all resources
  common_tags = merge(
    var.tags,
    {
      Name        = var.name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )

  # Conditional subnet selection
  subnet_ids = var.use_public_subnets ? var.public_subnet_ids : var.private_subnet_ids

  # Complex transformation
  instance_volume_map = flatten([
    for idx in range(var.instance_count) : [
      for vol_idx, vol in var.ebs_volumes : {
        instance_index = idx
        volume_index   = vol_idx
        volume_key     = "${idx}-${vol_idx}"
        # ...
      }
    ]
  ])
}
```

---

## Examples

### Example 1: Simple S3 Bucket Module

```hcl
# modules/s3-bucket-simple/main.tf
locals {
  bucket_name = "${var.name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Name        = local.bucket_name
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_s3_bucket" "this" {
  bucket = local.bucket_name

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status = var.enable_versioning ? "Enabled" : "Disabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  bucket = aws_s3_bucket.this.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}
```

### Example 2: VPC Module with Complex Subnets

See [vpc_module](../modules/vpc_module/) for a complete example of:
- Dynamic subnet creation
- Multi-AZ distribution
- Custom subnet groups
- VPC endpoints
- Comprehensive outputs

### Example 3: EC2 Module with EBS Volumes

See [ec2_scalable](../modules/ec2_scalable/) for a complete example of:
- Dynamic resource creation (multiple instances)
- Complex EBS volume management
- User data customization
- IAM integration
- Security best practices

---

## Checklist for New Modules

Before submitting a new module, ensure:

- [ ] Module follows standard directory structure
- [ ] All variables have descriptions and types
- [ ] Sensible defaults for optional variables
- [ ] Validation rules for critical inputs
- [ ] All outputs have descriptions
- [ ] Comprehensive README.md with examples
- [ ] Unit tests created and passing
- [ ] Integration tests created and passing
- [ ] Test fixtures demonstrate usage
- [ ] Code formatted with `terraform fmt`
- [ ] No hardcoded values (use variables)
- [ ] Tags applied to all taggable resources
- [ ] Secure defaults (encryption enabled, public access disabled)
- [ ] Follows naming conventions

---

## Getting Help

- Review existing modules: [vpc_module](../modules/vpc_module/), [ec2_scalable](../modules/ec2_scalable/)
- Check the [Testing Guide](./TESTING.md)
- Contact the infrastructure team

---

## Related Documentation

- [Testing Guide](./TESTING.md) - Comprehensive testing documentation
- [Main README](../README.md) - Repository overview
- [Module Documentation](../modules/) - Existing module examples
