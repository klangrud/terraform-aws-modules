# Networking & Infrastructure Modules

Modules for creating foundational network infrastructure including VPCs, subnets, gateways, and endpoints.

## vpc_module

### Overview

The `vpc_module` is the foundational networking module that creates a complete, production-ready VPC with multi-tier architecture. It supports public-facing resources, private application tiers, database subnets, and comprehensive security controls.

### Key Features

- **Multi-Tier Architecture**: Separate public, private, and RDS subnet tiers
- **High Availability**: Distributes subnets across multiple availability zones
- **Internet Connectivity**: Optional Internet Gateway for public subnets
- **NAT Gateway**: Enables private subnet internet access for updates and external API calls
- **VPC Endpoints**: Private connectivity to AWS services without internet gateway
- **Flow Logs**: Optional VPC flow logging for network monitoring
- **Custom Subnets**: Flexible custom subnet creation with per-subnet configuration
- **Security Groups**: Pre-configured security groups for different tiers

### Architecture Diagram

```
┌────────────────────────────────────────────────────────────────┐
│ VPC (10.0.0.0/16)                                              │
│                                                                │
│  ┌──────────────────┐   ┌──────────────────┐   ┌─────────────┐│
│  │ Availability     │   │ Availability     │   │ Availability││
│  │ Zone A           │   │ Zone B           │   │ Zone C      ││
│  │                  │   │                  │   │             ││
│  │ ┌─────────────┐  │   │ ┌─────────────┐  │   │ ┌─────────┐ ││
│  │ │ Public      │  │   │ │ Public      │  │   │ │ Public  │ ││
│  │ │ 10.0.1.0/24 │  │   │ │ 10.0.2.0/24 │  │   │ │10.0.3.  │ ││
│  │ │             │  │   │ │             │  │   │ │0/24     │ ││
│  │ │ ┌─────────┐ │  │   │ └─────────────┘  │   │ └─────────┘ ││
│  │ │ │NAT GW   │ │  │   │                  │   │             ││
│  │ │ └─────────┘ │  │   │                  │   │             ││
│  │ └─────────────┘  │   │                  │   │             ││
│  │                  │   │                  │   │             ││
│  │ ┌─────────────┐  │   │ ┌─────────────┐  │   │ ┌─────────┐ ││
│  │ │ Private     │  │   │ │ Private     │  │   │ │ Private │ ││
│  │ │ 10.0.11.0/24│  │   │ │ 10.0.12.0/24│  │   │ │10.0.13. │ ││
│  │ │             │  │   │ │             │  │   │ │0/24     │ ││
│  │ └─────────────┘  │   │ └─────────────┘  │   │ └─────────┘ ││
│  │                  │   │                  │   │             ││
│  │ ┌─────────────┐  │   │ ┌─────────────┐  │   │ ┌─────────┐ ││
│  │ │ RDS         │  │   │ │ RDS         │  │   │ │ RDS     │ ││
│  │ │ 10.0.21.0/24│  │   │ │ 10.0.22.0/24│  │   │ │10.0.23. │ ││
│  │ │             │  │   │ │             │  │   │ │0/24     │ ││
│  │ └─────────────┘  │   │ └─────────────┘  │   │ └─────────┘ ││
│  └──────────────────┘   └──────────────────┘   └─────────────┘│
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │ VPC Endpoints (S3, DynamoDB, ECR, SSM, etc.)             │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
         │                                      ▲
         │ Internet Gateway                     │ VPC Endpoints
         ▼                                      │
    Internet                              AWS Services
```

### Usage Example

#### Basic VPC

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name   = "production-vpc"
  region = "us-east-2"

  vpc_cidr              = "10.0.0.0/16"
  public_subnet_count   = 2
  private_subnet_count  = 2

  create_internet_gateway = true
  create_nat_gateway      = true

  tags = {
    Environment = "production"
    ManagedBy   = "terraform"
  }
}
```

#### VPC with RDS Subnets

```hcl
module "vpc_with_db" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name   = "app-vpc"
  region = "us-east-2"

  vpc_cidr              = "10.1.0.0/16"
  public_subnet_count   = 3
  private_subnet_count  = 3
  rds_subnet_count      = 3

  create_rds_subnets = true

  tags = {
    Application = "patient-portal"
    Environment = "production"
  }
}
```

#### VPC with Custom Subnets and VPC Endpoints

```hcl
module "vpc_advanced" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name   = "advanced-vpc"
  region = "us-east-2"

  vpc_cidr              = "10.2.0.0/16"
  public_subnet_count   = 2
  private_subnet_count  = 2

  # VPC Endpoints for private AWS service access
  vpc_endpoints = [
    "s3",
    "dynamodb",
    "ecr.api",
    "ecr.dkr",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "logs"
  ]

  # Custom subnets for specialized workloads
  custom_subnets = [
    {
      name                    = "ml-training"
      availability_zone       = "us-east-2a"
      cidr_block             = "10.2.100.0/24"
      map_public_ip_on_launch = false
      route_table            = "private"
    },
    {
      name                    = "data-processing"
      availability_zone       = "us-east-2b"
      cidr_block             = "10.2.101.0/24"
      map_public_ip_on_launch = false
      route_table            = "private"
    }
  ]

  # Enable VPC flow logs for security monitoring
  create_vpc_flow_logs = true

  tags = {
    Environment = "production"
    Purpose     = "ml-infrastructure"
  }
}
```

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `name` | string | VPC name used for tagging |
| `region` | string | AWS region |
| `vpc_cidr` | string | CIDR block for VPC |
| `tags` | map(string) | Tags to apply to all resources |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `public_subnet_count` | number | 0 | Number of public subnets (max 6) |
| `private_subnet_count` | number | 0 | Number of private subnets (max 6) |
| `rds_subnet_count` | number | 0 | Number of RDS subnets (max 6) |
| `create_internet_gateway` | bool | true | Create Internet Gateway |
| `create_nat_gateway` | bool | true | Create NAT Gateway in first public subnet |
| `create_rds_subnets` | bool | false | Create RDS subnet group |
| `create_vpc_flow_logs` | bool | false | Enable VPC flow logging |
| `vpc_endpoints` | list(string) | [] | AWS services for VPC endpoints |
| `custom_subnets` | list(object) | [] | Custom subnet configurations |

#### VPC Endpoint Options

Supported AWS services for VPC endpoints:
- `s3` - S3 Gateway Endpoint
- `dynamodb` - DynamoDB Gateway Endpoint
- `ecr.api` - ECR API Interface Endpoint
- `ecr.dkr` - ECR Docker Interface Endpoint
- `ssm` - Systems Manager Interface Endpoint
- `ssmmessages` - SSM Session Manager Interface Endpoint
- `ec2messages` - EC2 Messages Interface Endpoint
- `logs` - CloudWatch Logs Interface Endpoint
- `kms` - KMS Interface Endpoint
- `secretsmanager` - Secrets Manager Interface Endpoint

### Outputs

| Output | Description |
|--------|-------------|
| `vpc_id` | VPC ID |
| `public_subnets` | List of public subnet IDs |
| `private_subnets` | List of private subnet IDs |
| `rds_subnets` | List of RDS subnet IDs |
| `custom_subnets` | List of custom subnet IDs |
| `custom_subnets_by_name` | Map of custom subnet names to IDs |
| `internet_gateway_id` | Internet Gateway ID |
| `nat_gateway_id` | NAT Gateway ID |
| `public_route_table_id` | Public route table ID |
| `private_route_table_id` | Private route table ID |
| `vpc_endpoints` | Map of VPC endpoint IDs |
| `default_security_group_id` | Default VPC security group ID |
| `public_security_group_id` | Public subnet security group ID |
| `private_security_group_id` | Private subnet security group ID |
| `rds_security_group_id` | RDS subnet security group ID |

### Security Groups Created

1. **Default Security Group**: Default VPC security group (no rules)
2. **Public Security Group**: For resources in public subnets
   - Ingress: None by default
   - Egress: All traffic allowed
3. **Private Security Group**: For resources in private subnets
   - Ingress: All from VPC CIDR
   - Egress: All traffic allowed
4. **RDS Security Group**: For RDS instances
   - Ingress: PostgreSQL (5432) and MySQL (3306) from VPC CIDR
   - Egress: None
5. **VPC Endpoint Security Group**: For VPC endpoints
   - Ingress: HTTPS (443) from VPC CIDR
   - Egress: None

### Supported VPC CIDR Sizes

The module supports VPC CIDR blocks from /16 to /24. Subnet sizes are automatically calculated to meet AWS's minimum subnet size (/28 = 16 IPs).

| VPC CIDR | Total IPs | Public/Private Subnets | RDS/Custom Subnets | Use Case |
|----------|-----------|------------------------|--------------------| ---------|
| **/16** | 65,536 | /20 (4,096 IPs each) | /24 (256 IPs each) | Large production environments |
| **/17** | 32,768 | /21 (2,048 IPs each) | /25 (128 IPs each) | Medium-large environments |
| **/18** | 16,384 | /22 (1,024 IPs each) | /26 (64 IPs each) | Medium environments |
| **/19** | 8,192 | /23 (512 IPs each) | /27 (32 IPs each) | Small-medium environments |
| **/20** | 4,096 | /24 (256 IPs each) | /28 (16 IPs each) | Small environments |
| **/21** | 2,048 | /25 (128 IPs each) | /28 (16 IPs each) | Dev/test environments |
| **/22** | 1,024 | /26 (64 IPs each) | /28 (16 IPs each) | Small dev/test |
| **/23** | 512 | /27 (32 IPs each) | /28 (16 IPs each) | Minimal environments |
| **/24** | 256 | /28 (16 IPs each) | /28 (16 IPs each) | Single-purpose VPCs |

**Notes:**
- AWS reserves 5 IPs per subnet (usable = total - 5)
- VPCs smaller than /24 are not supported
- For /21-/24 VPCs, RDS and custom subnets use /28 (AWS minimum)

### Subnet CIDR Calculation

Subnets are automatically calculated based on the VPC CIDR. For a /16 VPC (`10.0.0.0/16`):

- **Public Subnets**: /20 blocks at indices 0-5 (e.g., `10.0.0.0/20`, `10.0.16.0/20`)
- **Private Subnets**: /20 blocks at indices 6-11 (e.g., `10.0.96.0/20`, `10.0.112.0/20`)
- **RDS Subnets**: /24 blocks at indices 200+ (e.g., `10.0.200.0/24`, `10.0.201.0/24`)

For smaller VPCs, subnet sizes scale automatically while maintaining the AWS minimum of /28.

### Custom Subnet Configuration

Custom subnets provide flexibility for specialized workloads:

```hcl
custom_subnets = [
  {
    name                    = "subnet-name"
    availability_zone       = "us-east-2a"
    cidr_block             = "10.0.100.0/24"
    map_public_ip_on_launch = false
    route_table            = "private"  # or "public"
  }
]
```

### Best Practices

1. **Choose the Right VPC Size**: See the [Supported VPC CIDR Sizes](#supported-vpc-cidr-sizes) table
   - Production: /16 to /19 for maximum flexibility
   - Dev/Test: /20 to /22 for cost efficiency
   - Single-purpose: /23 to /24 for minimal footprint
2. **High Availability**: Use at least 2 AZs (2 subnets per tier)
3. **Production**: Use 3 AZs (3 subnets per tier) for maximum availability
4. **VPC Endpoints**: Use endpoints for private AWS service access (reduces NAT costs)
5. **Flow Logs**: Enable in production for security monitoring
6. **NAT Gateway**: Required for private subnet internet access (updates, external APIs)
7. **Security Groups**: Leverage the pre-configured security groups, customize as needed

### Common Use Cases

#### Use Case 1: Web Application with Database

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name                  = "webapp-vpc"
  region                = "us-east-2"
  vpc_cidr              = "10.0.0.0/16"
  public_subnet_count   = 2    # For load balancers
  private_subnet_count  = 2    # For application servers
  rds_subnet_count      = 2    # For RDS database
  create_rds_subnets    = true

  vpc_endpoints = ["s3", "secretsmanager"]

  tags = {
    Application = "web-app"
    Environment = "production"
  }
}
```

#### Use Case 2: ECS Fargate Cluster

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name                 = "ecs-vpc"
  region               = "us-east-2"
  vpc_cidr             = "10.0.0.0/16"
  public_subnet_count  = 3    # For ALB
  private_subnet_count = 3    # For ECS tasks

  # VPC endpoints reduce NAT costs for ECS
  vpc_endpoints = [
    "ecr.api",
    "ecr.dkr",
    "s3",
    "logs",
    "secretsmanager"
  ]

  tags = {
    Application = "ecs-cluster"
    Environment = "production"
  }
}
```

#### Use Case 3: Private Data Processing Environment

```hcl
module "vpc" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/vpc_module?ref=main"

  name                    = "data-vpc"
  region                  = "us-east-2"
  vpc_cidr                = "10.0.0.0/16"
  private_subnet_count    = 3
  create_internet_gateway = false  # No public internet access
  create_nat_gateway      = false  # No outbound internet

  # All AWS service access via VPC endpoints
  vpc_endpoints = [
    "s3",
    "dynamodb",
    "ssm",
    "ssmmessages",
    "ec2messages",
    "kms",
    "secretsmanager"
  ]

  create_vpc_flow_logs = true  # Enhanced monitoring

  tags = {
    Environment = "production"
    Compliance  = "HIPAA"
  }
}
```

### Troubleshooting

#### Issue: Subnets not distributing across AZs

**Cause**: Region has fewer AZs than requested subnets

**Solution**: Reduce subnet count or accept uneven distribution

#### Issue: NAT Gateway cost concerns

**Cause**: High data transfer through NAT Gateway

**Solution**:
- Add VPC endpoints for frequently used AWS services
- Use S3 Gateway Endpoint (free) instead of NAT for S3 access
- Consider consolidating to single NAT Gateway (reduces HA)

#### Issue: VPC endpoint connection failures

**Cause**: Security group not allowing HTTPS traffic

**Solution**: Ensure VPC endpoint security group allows port 443 from VPC CIDR

#### Issue: Flow logs not appearing in CloudWatch

**Cause**: IAM role permissions or log group misconfiguration

**Solution**: Verify CloudWatch log group exists and IAM role has write permissions

### Related Modules

- **ec2_scalable**: Deploys EC2 instances in VPC subnets
- **container_automation_ecs**: Deploys ECS tasks in VPC subnets
- **s3_bucket**: Can be accessed via S3 VPC endpoint

### Cost Considerations

- **NAT Gateway**: ~$0.045/hour + data transfer ($0.045/GB)
- **VPC Endpoints**: ~$0.01/hour per endpoint + data transfer ($0.01/GB)
- **Gateway Endpoints (S3, DynamoDB)**: Free
- **Flow Logs**: CloudWatch Logs storage costs
- **VPC itself**: Free

**Optimization Tips**:
- Use Gateway Endpoints for S3 and DynamoDB (free)
- Interface endpoints cost less than NAT for high-volume AWS service access
- Single NAT Gateway saves ~$0.045/hour but reduces availability
