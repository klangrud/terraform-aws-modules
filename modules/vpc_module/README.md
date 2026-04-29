# VPC Module

A comprehensive Terraform module for creating AWS VPCs with flexible subnet configurations, NAT gateways, internet gateways, VPC endpoints, and flow logs.

## Features

- **Flexible Subnet Allocation**: Create public, private, and RDS subnets across multiple availability zones
- **Custom Subnets**: Define custom subnet groups with configurable public/private routing
- **NAT Gateway**: Optional NAT gateway for private subnet internet access
- **Internet Gateway**: Optional internet gateway for public subnet access
- **VPC Endpoints**: Support for creating VPC endpoints for AWS services
- **VPC Flow Logs**: Optional VPC flow logging to CloudWatch
- **Multi-AZ Support**: Distribute subnets across availability zones (1-6 AZs supported)
- **Automatic CIDR Allocation**: Automatically calculates subnet CIDRs from VPC CIDR block
- **Resource Tagging**: Comprehensive tagging support for all resources

## Usage Examples

### Basic VPC with Public and Private Subnets

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.0.0"

  name     = "my-application"
  region   = "us-east-1"
  vpc_cidr = "10.0.0.0/16"

  # Create 3 public and 3 private subnets across 3 AZs
  public_subnet_count  = 3
  private_subnet_count = 3

  # Enable internet and NAT gateways
  create_internet_gateway = true
  create_nat_gateway      = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

### VPC with RDS Subnets

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.0.0"

  name     = "database-vpc"
  region   = "us-east-1"
  vpc_cidr = "10.1.0.0/16"

  # Create subnets for application and database tiers
  public_subnet_count  = 2
  private_subnet_count = 2

  # Enable RDS subnets
  create_rds_subnets = true
  rds_subnet_count   = 3

  create_internet_gateway = true
  create_nat_gateway      = true

  tags = {
    Environment = "production"
    Project     = "healthcare-db"
  }
}
```

### VPC with Custom Subnets

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.0.0"

  name     = "multi-tier-vpc"
  region   = "us-west-2"
  vpc_cidr = "10.2.0.0/16"

  # Define custom subnet groups
  custom_subnets = [
    {
      name         = "app"
      public       = false
      subnet_count = 3
    },
    {
      name         = "data"
      public       = false
      subnet_count = 3
    },
    {
      name         = "dmz"
      public       = true
      subnet_count = 2
    }
  ]

  create_internet_gateway = true
  create_nat_gateway      = true

  tags = {
    Environment = "production"
    Tier        = "multi-tier"
  }
}
```

### VPC with VPC Endpoints and Flow Logs

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=v1.0.0"

  name     = "secure-vpc"
  region   = "us-east-1"
  vpc_cidr = "10.3.0.0/16"

  public_subnet_count  = 2
  private_subnet_count = 3

  # Enable VPC endpoints for AWS services
  vpc_endpoints = [
    "s3",
    "ec2",
    "ecr.api",
    "ecr.dkr",
    "logs"
  ]

  # Enable VPC flow logs
  create_vpc_flow_logs = true

  create_internet_gateway = true
  create_nat_gateway      = true

  tags = {
    Environment = "production"
    Compliance  = "HIPAA"
  }
}
```

## Local Testing

This module includes comprehensive tests using [Terratest](https://terratest.gruntwork.io/). You can test the module locally before using it in production.

### Prerequisites

- Go 1.21+
- Terraform 1.6+
- AWS credentials configured

### Running Tests

Navigate to the repository root and use the test runner:

```bash
# Run unit tests (fast, no AWS resources created)
./run-tests.sh unit

# Run integration tests (creates real AWS resources)
export AWS_PROFILE=your-profile
./run-tests.sh integration

# Run all tests
./run-tests.sh all
```

### Manual Test Execution

```bash
cd test/vpc_module

# Unit tests only
go test -v -tags=unit ./... -timeout 10m

# Integration tests only
go test -v -tags=integration ./... -timeout 30m

# Specific test
go test -v -tags=unit -run TestCustomSubnetSpacing ./... -timeout 10m
```

### Test Fixtures

Test fixtures are located in `test/vpc_module/fixtures/`. Each fixture demonstrates different module configurations:

- **basic/**: Basic VPC with public and private subnets
- **custom-subnet-test/**: Custom subnet configurations
- **endpoint-test/**: VPC endpoint configurations
- **rds-subnet-test/**: RDS subnet configurations
- **tag-test/**: Resource tagging validation

You can use these fixtures as reference examples for your own implementations.

## Architecture

### Supported VPC CIDR Sizes

The module supports VPC CIDR blocks from /16 to /24. Subnet sizes are automatically calculated to ensure they meet AWS's minimum subnet size requirement (/28 = 16 IPs).

| VPC CIDR | Total IPs | Public/Private Subnets | RDS/Custom Subnets | Max Subnets | Use Case |
|----------|-----------|------------------------|--------------------|--------------| ---------|
| **/16** | 65,536 | /20 (4,096 IPs each) | /24 (256 IPs each) | 6 per type | Large production environments |
| **/17** | 32,768 | /21 (2,048 IPs each) | /25 (128 IPs each) | 6 per type | Medium-large environments |
| **/18** | 16,384 | /22 (1,024 IPs each) | /26 (64 IPs each) | 6 per type | Medium environments |
| **/19** | 8,192 | /23 (512 IPs each) | /27 (32 IPs each) | 6 per type | Small-medium environments |
| **/20** | 4,096 | /24 (256 IPs each) | /28 (16 IPs each) | 6 per type | Small environments |
| **/21** | 2,048 | /25 (128 IPs each) | /28 (16 IPs each) | 6 per type | Dev/test environments |
| **/22** | 1,024 | /26 (64 IPs each) | /28 (16 IPs each) | 6 per type | Small dev/test |
| **/23** | 512 | /27 (32 IPs each) | /28 (16 IPs each) | 6 per type | Minimal environments |
| **/24** | 256 | /28 (16 IPs each) | /28 (16 IPs each) | 6 per type | Single-purpose VPCs |

**Notes:**
- AWS requires a minimum subnet size of /28 (16 IPs, 11 usable after AWS reservations)
- VPCs smaller than /24 are not supported (cannot create valid subnets)
- For /21-/24 VPCs, RDS and custom subnets use /28 (the AWS minimum)
- Usable IPs per subnet = Total IPs - 5 (AWS reserves 5 IPs per subnet)

### Subnet CIDR Allocation

The module automatically calculates subnet CIDRs from the VPC CIDR block. Example for a /16 VPC (`10.0.0.0/16`):

- **Public Subnets**: `10.0.0.0/20`, `10.0.16.0/20`, `10.0.32.0/20` (indices 0-5)
- **Private Subnets**: `10.0.96.0/20`, `10.0.112.0/20`, `10.0.128.0/20` (indices 6-11)
- **RDS Subnets**: `10.0.200.0/24`, `10.0.201.0/24`, `10.0.202.0/24` (indices 200+)
- **Custom Subnets**: `10.0.198.0/24`, `10.0.199.0/24`, etc. (indices 198+)

For smaller VPCs (e.g., /24), all subnets become /28 and use sequential indices to fit within the available address space.

### Multi-AZ Distribution

Subnets are automatically distributed across availability zones:

- 1 AZ: All subnets in single AZ
- 2 AZs: Subnets alternate between AZs
- 3+ AZs: Subnets distributed evenly

### Routing

- **Public Subnets**: Route to Internet Gateway (0.0.0.0/0 → IGW)
- **Private Subnets**: Route to NAT Gateway (0.0.0.0/0 → NAT)
- **RDS Subnets**: Private routing (no direct internet access)
- **Custom Subnets**: Public or private routing based on configuration

## Cost Considerations

### S3 and DynamoDB: Use Free Gateway Endpoints

By default, traffic from private subnets to S3 or DynamoDB routes through the NAT Gateway. AWS charges **~$0.045 per GB** of data processed by the NAT Gateway, which adds up quickly for workloads that read/write S3 frequently (e.g., application logs, ML training data, container image layers via ECR backed by S3).

**S3 and DynamoDB Gateway Endpoints are free.** Adding them bypasses the NAT Gateway entirely for that traffic, routing it directly over the AWS backbone instead.

```hcl
module "vpc" {
  # ...
  vpc_endpoints = ["s3", "dynamodb"]
}
```

This is one of the highest-value, lowest-effort cost optimizations available in AWS networking. It is strongly recommended for any VPC where private subnets access S3 or DynamoDB.

### NAT Gateway High Availability vs. Cost

The `nat_gateway_per_az` variable controls the availability/cost tradeoff for outbound internet access from private subnets:

| Setting | NAT Gateways | Cost | Availability |
|---|---|---|---|
| `nat_gateway_per_az = false` (default) | 1 | Lower | Single point of failure |
| `nat_gateway_per_az = true` | 1 per AZ | Higher | Survives AZ failure |

For production workloads, per-AZ gateways are recommended. For dev/test, a single gateway is usually sufficient.

## Best Practices

1. **Choose the Right VPC Size**: Use the [Supported VPC CIDR Sizes](#supported-vpc-cidr-sizes) table to select an appropriate size:
   - Production workloads: /16 to /19 for maximum flexibility
   - Development/test: /20 to /22 for cost efficiency
   - Single-purpose VPCs: /23 to /24 for minimal footprint
2. **Use Custom Subnets for Complex Architectures**: For multi-tier applications, use `custom_subnets` to define application-specific subnet groups
3. **Enable Flow Logs for Production**: Always enable `create_vpc_flow_logs = true` for production VPCs
4. **Use VPC Endpoints**: Add VPC endpoints for frequently used AWS services to reduce NAT gateway costs
5. **Tag Resources**: Always provide meaningful tags for cost allocation and resource management
6. **Test Configurations**: Use the provided test fixtures to validate your configuration before deployment

## Limitations

- **VPC CIDR Size**: Must be between /16 and /24 (smaller VPCs cannot support AWS minimum subnet size)
- **Maximum Subnets**: 6 subnets per type (limited by AZ count in most regions)
- **NAT Gateway**: Creates a single gateway in the first public subnet (not HA by default)
- **VPC Endpoints**: Gateway endpoints (S3, DynamoDB) and Interface endpoints are both supported
- **Small VPC Considerations**: For /21-/24 VPCs, RDS and custom subnets use /28 (16 IPs, 11 usable)

## Related Documentation

- [Testing Guide](../../docs/TESTING.md) - Comprehensive testing documentation
- [Module Development Guide](../../docs/MODULE_DEVELOPMENT.md) - Guide for module developers
- [AWS VPC Documentation](https://docs.aws.amazon.com/vpc/)

## Support

For issues or questions:
1. Check the [Testing Guide](../../docs/TESTING.md) for test examples
2. Review test fixtures in `test/vpc_module/fixtures/`
3. Contact the infrastructure team

---

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
| [aws_cloudwatch_log_group.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eip.nat](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_flow_log.vpc](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/flow_log) | resource |
| [aws_iam_role.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.vpc_flow_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_internet_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_nat_gateway.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/nat_gateway) | resource |
| [aws_route.private_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route.public_internet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route_table.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_route_table_association.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.custom](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.default](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.vpc_endpoints](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.custom_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_endpoint.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_endpoint) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_custom_subnets"></a> [additional\_custom\_subnets](#input\_additional\_custom\_subnets) | n/a | <pre>map(object({<br>    type       = string<br>    cidr_block = string<br>  }))</pre> | n/a | yes |
| <a name="input_create_internet_gateway"></a> [create\_internet\_gateway](#input\_create\_internet\_gateway) | n/a | `bool` | `true` | no |
| <a name="input_create_nat_gateway"></a> [create\_nat\_gateway](#input\_create\_nat\_gateway) | n/a | `bool` | `true` | no |
| <a name="input_create_rds_subnets"></a> [create\_rds\_subnets](#input\_create\_rds\_subnets) | Whether to create RDS subnets | `bool` | `false` | no |
| <a name="input_create_vpc_flow_logs"></a> [create\_vpc\_flow\_logs](#input\_create\_vpc\_flow\_logs) | Whether to create VPC flow logs and related resources | `bool` | `false` | no |
| <a name="input_custom_subnets"></a> [custom\_subnets](#input\_custom\_subnets) | List of custom subnets with name, public flag, and subnet\_count (number of /24 subnets to allocate). Example: [ { name = "app-subnet", public = false, subnet\_count = 3 } ] | <pre>list(object({<br>    name         = string<br>    public       = bool<br>    subnet_count = number<br>  }))</pre> | `[]` | no |
| <a name="input_mock_azs"></a> [mock\_azs](#input\_mock\_azs) | Mock AZs used for testing | `list(string)` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | n/a | `string` | n/a | yes |
| <a name="input_private_subnet_count"></a> [private\_subnet\_count](#input\_private\_subnet\_count) | How many private subnets (AZs) to allocate, default is 3. Max 6. | `number` | `3` | no |
| <a name="input_public_subnet_count"></a> [public\_subnet\_count](#input\_public\_subnet\_count) | How many public subnets (AZs) to allocate, default is 3. Max 6. | `number` | `3` | no |
| <a name="input_rds_subnet_count"></a> [rds\_subnet\_count](#input\_rds\_subnet\_count) | How many RDS subnets (AZs) to allocate, default is 3. Max 6. | `number` | `3` | no |
| <a name="input_region"></a> [region](#input\_region) | n/a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | n/a | `map(string)` | `{}` | no |
| <a name="input_test_resource_tag"></a> [test\_resource\_tag](#input\_test\_resource\_tag) | Optional tag to mark resources created by automated tests for cleanup. Leave empty in normal usage. | `string` | `""` | no |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | The CIDR block for the VPC | `string` | n/a | yes |
| <a name="input_vpc_endpoints"></a> [vpc\_endpoints](#input\_vpc\_endpoints) | List of AWS services to create VPC endpoints for | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_custom_subnet_azs"></a> [custom\_subnet\_azs](#output\_custom\_subnet\_azs) | List of availability zones for custom subnets |
| <a name="output_custom_subnet_cidrs"></a> [custom\_subnet\_cidrs](#output\_custom\_subnet\_cidrs) | List of custom subnet CIDR blocks |
| <a name="output_custom_subnet_ids"></a> [custom\_subnet\_ids](#output\_custom\_subnet\_ids) | n/a |
| <a name="output_custom_subnets_by_name"></a> [custom\_subnets\_by\_name](#output\_custom\_subnets\_by\_name) | Map of custom subnets by name, with ID, CIDR, and AZ |
| <a name="output_internet_gateway_id"></a> [internet\_gateway\_id](#output\_internet\_gateway\_id) | ID of the internet gateway if created |
| <a name="output_nat_gateway_id"></a> [nat\_gateway\_id](#output\_nat\_gateway\_id) | The ID of the NAT Gateway if created |
| <a name="output_private_route_table_ids"></a> [private\_route\_table\_ids](#output\_private\_route\_table\_ids) | List of route table IDs associated with private subnets |
| <a name="output_private_subnet_ids"></a> [private\_subnet\_ids](#output\_private\_subnet\_ids) | Alias of private\_subnets for clarity |
| <a name="output_private_subnets"></a> [private\_subnets](#output\_private\_subnets) | n/a |
| <a name="output_public_route_table_ids"></a> [public\_route\_table\_ids](#output\_public\_route\_table\_ids) | List of route table IDs associated with public subnets |
| <a name="output_public_subnet_ids"></a> [public\_subnet\_ids](#output\_public\_subnet\_ids) | Alias of public\_subnets for clarity |
| <a name="output_public_subnets"></a> [public\_subnets](#output\_public\_subnets) | n/a |
| <a name="output_rds_subnet_ids"></a> [rds\_subnet\_ids](#output\_rds\_subnet\_ids) | List of RDS Subnet IDs |
| <a name="output_rds_subnets"></a> [rds\_subnets](#output\_rds\_subnets) | List of RDS subnet IDs (if created) |
| <a name="output_vpc_endpoints"></a> [vpc\_endpoints](#output\_vpc\_endpoints) | Map of VPC endpoints created |
| <a name="output_vpc_flow_log_group_name"></a> [vpc\_flow\_log\_group\_name](#output\_vpc\_flow\_log\_group\_name) | Name of the VPC flow log CloudWatch Log Group |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | outputs.tf |
<!-- END_TF_DOCS -->
