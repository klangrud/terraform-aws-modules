# Compute & Container Modules

Modules for deploying compute resources including EC2 instances and ECS containerized applications.

## Table of Contents

- [ec2_scalable](#ec2_scalable)
- [container_automation_ecs](#container_automation_ecs)
- [ec2_user_data](#ec2_user_data)

---

## ec2_scalable

### Overview

The `ec2_scalable` module deploys fully-configured EC2 instances with comprehensive networking, security, and systems management capabilities. Supports single or multiple instances (1-100) with dynamic EBS volume management, automatic filesystem mounting, and best-practice security configurations.

### Key Features

- **Scalable Architecture**: Deploy 1 to 100 EC2 instances with a single module call
- **Automatic EBS Management**: Dynamically create, attach, format, and mount EBS volumes
- **Secure by Default**: IMDSv2 enforced, encrypted EBS volumes, API termination protection
- **Systems Manager Access**: SSM Session Manager for secure shell access without SSH keys
- **Cost-Effective**: Defaults to `t3a.medium` for optimal price/performance
- **Automated Security Updates**: Apply security patches on first boot
- **Multi-Subnet Distribution**: Instances distributed across provided subnets for HA
- **IAM Integration**: Auto-creates IAM instance profile with SSM permissions

### Architecture

```
┌─────────────────────────────────────────────────────────┐
│ VPC                                                     │
│                                                         │
│  ┌────────────────────────────────────────────────┐    │
│  │ Private Subnet(s)                              │    │
│  │                                                 │    │
│  │  ┌──────────────────────────────────────────┐  │    │
│  │  │ EC2 Instance(s)                          │  │    │
│  │  │                                           │  │    │
│  │  │ • IAM Role (SSM permissions)             │  │    │
│  │  │ • Security Group (configurable)          │  │    │
│  │  │ • Root Volume (gp3, encrypted)           │  │    │
│  │  │ • Additional EBS Volumes (auto-mounted)  │  │    │
│  │  │ • User Data:                             │  │    │
│  │  │   - Mount EBS volumes                    │  │    │
│  │  │   - Install SSM agent                    │  │    │
│  │  │   - Security updates                     │  │    │
│  │  │   - Custom scripts                       │  │    │
│  │  └──────────────────────────────────────────┘  │    │
│  └────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────┘
```

### Usage Examples

#### Basic Single Instance

```hcl
module "app_server" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=main"

  project_name = "my-app"
  env_short    = "prod"

  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [module.vpc.private_subnets[0]]
  ec2_key_pair = "my-keypair"

  tags = {
    Application = "my-app"
    Environment = "production"
  }
}
```

#### Instance with /data Volume

```hcl
module "research_hub" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=main"

  project_name = "research-hub"
  env_short    = "prod"

  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [module.vpc.private_subnets[0]]
  ec2_key_pair = "research-keypair"

  instance_type = "t3a.large"

  # Enable /data volume
  enable_data_volume = true
  data_volume_size   = 500  # 500 GB

  tags = {
    Application = "research-hub"
    Environment = "production"
  }
}
```

#### Multiple Instances with Custom EBS Volumes

```hcl
module "app_cluster" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=main"

  project_name   = "app-cluster"
  env_short      = "prod"
  instance_count = 3  # Deploy 3 instances across subnets

  vpc_id = module.vpc.vpc_id
  subnet_ids = [
    module.vpc.private_subnets[0],  # us-east-1a
    module.vpc.private_subnets[1],  # us-east-1b
    module.vpc.private_subnets[2]   # us-east-1c
  ]
  ec2_key_pair = "cluster-keypair"

  instance_type = "m5.xlarge"

  # Multiple custom EBS volumes
  additional_ebs_volumes = [
    {
      device_name = "/dev/sdf"
      mount_point = "/var/lib/postgresql"
      volume_size = 500
      volume_type = "gp3"
      iops        = 10000
      throughput  = 500
      filesystem  = "ext4"
    },
    {
      device_name = "/dev/sdg"
      mount_point = "/backup"
      volume_size = 1000
      volume_type = "gp3"
    }
  ]

  # Security group configuration
  allowed_cidr_blocks     = ["10.0.0.0/8"]
  allowed_ssh_cidr_blocks = ["10.10.0.0/16"]

  tags = {
    Application = "app-cluster"
    Environment = "production"
  }
}
```

#### Custom User Data

```hcl
module "custom_app" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=main"

  project_name = "custom-app"
  env_short    = "prod"

  vpc_id       = module.vpc.vpc_id
  subnet_ids   = [module.vpc.private_subnets[0]]
  ec2_key_pair = "custom-keypair"

  # Custom user data scripts
  custom_user_data_parts = [
    {
      content_type = "text/x-shellscript"
      filename     = "50-install-docker.sh"
      content      = <<-EOF
        #!/bin/bash
        set -e
        yum install -y docker
        systemctl enable docker
        systemctl start docker
        usermod -aG docker ec2-user
      EOF
    }
  ]

  tags = {
    Application = "custom-app"
    Environment = "production"
  }
}
```

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `project_name` | string | Project name for resource naming |
| `env_short` | string | Environment short name (dev, test, prod) |
| `vpc_id` | string | VPC ID |
| `subnet_ids` | list(string) | Subnet IDs for instance placement |
| `ec2_key_pair` | string | EC2 Key Pair name |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `ami_id` | string | Amazon Linux 2023 | AMI ID for EC2 instances |
| `instance_type` | string | "t3a.medium" | EC2 instance type |
| `instance_count` | number | 1 | Number of instances (1-100) |
| `enable_data_volume` | bool | false | Enable default /data volume |
| `data_volume_size` | number | 100 | Size of /data volume in GB |
| `additional_ebs_volumes` | list(object) | [] | Additional EBS volumes |
| `create_security_group` | bool | true | Create default security group |
| `allowed_cidr_blocks` | list(string) | [] | CIDRs allowed access |
| `allowed_ssh_cidr_blocks` | list(string) | [] | CIDRs allowed SSH access |
| `create_iam_instance_profile` | bool | true | Create IAM instance profile |
| `enable_security_updates` | bool | true | Apply security updates on boot |
| `install_ssm_agent` | bool | true | Install AWS SSM Agent |
| `custom_user_data_parts` | list(object) | [] | Custom cloud-init parts |
| `disable_api_termination` | bool | true | Enable termination protection |
| `enable_detailed_monitoring` | bool | false | CloudWatch detailed monitoring |
| `tags` | map(string) | {} | Resource tags |

### Outputs

| Output | Description |
|--------|-------------|
| `instance_ids` | List of EC2 instance IDs |
| `instance_private_ips` | List of private IP addresses |
| `instance_public_ips` | List of public IP addresses (if applicable) |
| `instance_arns` | List of EC2 instance ARNs |
| `security_group_id` | Security group ID (if created) |
| `iam_role_arn` | IAM role ARN (if created) |
| `iam_role_name` | IAM role name (if created) |
| `ebs_volume_ids` | Map of EBS volume IDs |
| `instance_details` | Detailed information about each instance |

### EBS Volume Auto-Mounting

The module automatically handles:
1. **Device Detection**: Detects both classic (xvdf) and NVMe (nvme1n1) device naming
2. **Filesystem Creation**: Creates ext4/xfs filesystem if not present
3. **Mounting**: Mounts volumes to specified mount points
4. **Persistence**: Adds UUID-based fstab entries for persistence across reboots

### Connecting to Instances

Use AWS Systems Manager Session Manager:

```bash
# Via AWS CLI
aws ssm start-session --target i-1234567890abcdef0

# Via AWS Console
# Navigate to Systems Manager → Session Manager → Start Session
```

No SSH keys or bastion hosts required!

### Best Practices

1. **Use Private Subnets**: Never deploy in public subnets
2. **Encrypted Volumes**: Always encrypt EBS volumes (default in module)
3. **IAM Roles**: Module creates SSM-enabled IAM role automatically
4. **Monitoring**: Enable detailed monitoring for production workloads
5. **Multi-AZ**: Use multiple subnets for high availability
6. **Instance Sizing**: Start small, scale up based on CloudWatch metrics
7. **Version Pinning**: Always specify `?ref=vX.Y.Z` in source

---

## container_automation_ecs

### Overview

The `container_automation_ecs` module simplifies ECS task definition creation by automatically detecting the latest container image from ECR. This eliminates manual image tag management and streamlines container deployments.

### Key Features

- **Automatic Image Detection**: Fetches most recent image from ECR
- **Fargate Support**: Optional Fargate compatibility
- **Flexible Configuration**: Supports multiple container definitions
- **Resource Management**: Configurable CPU and memory allocation
- **IAM Integration**: Separate task and execution role support

### Usage Example

#### Basic ECS Task Definition

```hcl
module "app_task" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/container_automation_ecs?ref=main"

  aws_ecr_image_repository_name = "my-application"
  family                        = "my-app-task"

  container_definitions = [
    {
      name      = "app-container"
      image     = "my-application:latest"  # Will be replaced with ECR image
      cpu       = 256
      memory    = 512
      essential = true

      environment = [
        { name = "ENV", value = "production" },
        { name = "LOG_LEVEL", value = "INFO" }
      ]

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/my-app"
          "awslogs-region"        = "us-east-2"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ]

  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.execution_role.arn

  tags = {
    Application = "my-app"
    Environment = "production"
  }
}
```

#### Fargate Task Definition

```hcl
module "fargate_task" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/container_automation_ecs?ref=main"

  aws_ecr_image_repository_name = "web-api"
  family                        = "web-api-fargate"

  fargate = true
  cpu     = "1024"   # Fargate requires specific CPU values
  memory  = "2048"   # Fargate requires specific memory values

  container_definitions = [
    {
      name      = "web-api"
      image     = "web-api:latest"
      cpu       = 1024
      memory    = 2048
      essential = true

      environment = [
        { name = "AWS_REGION", value = "us-east-2" }
      ]

      secrets = [
        {
          name      = "DB_PASSWORD"
          valueFrom = "arn:aws:secretsmanager:us-east-2:123456789012:secret:db-password"
        }
      ]

      portMappings = [
        {
          containerPort = 443
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/web-api"
          "awslogs-region"        = "us-east-2"
          "awslogs-stream-prefix" = "fargate"
        }
      }
    }
  ]

  operating_system_family = "LINUX"
  cpu_architecture        = "X86_64"

  task_role_arn      = aws_iam_role.task_role.arn
  execution_role_arn = aws_iam_role.execution_role.arn

  tags = {
    Application = "web-api"
    Environment = "production"
    LaunchType  = "FARGATE"
  }
}
```

### Configuration Reference

#### Required Variables

| Variable | Type | Description |
|----------|------|-------------|
| `aws_ecr_image_repository_name` | string | ECR repository name |
| `family` | string | Task definition family name |
| `container_definitions` | list(object) | Container configurations |
| `task_role_arn` | string | IAM role for task |
| `execution_role_arn` | string | IAM role for execution |
| `tags` | map(string) | Resource tags |

#### Optional Variables

| Variable | Type | Default | Description |
|----------|------|---------|-------------|
| `fargate` | bool | false | Enable Fargate compatibility |
| `cpu` | string | "256" | Task CPU units |
| `memory` | string | "512" | Task memory in MB |
| `operating_system_family` | string | "LINUX" | OS family |
| `cpu_architecture` | string | "X86_64" | CPU architecture |

#### Fargate CPU and Memory Combinations

| CPU (vCPU) | Memory Options (MB) |
|------------|---------------------|
| 256 (.25)  | 512, 1024, 2048 |
| 512 (.5)   | 1024, 2048, 3072, 4096 |
| 1024 (1)   | 2048, 3072, 4096, 5120, 6144, 7168, 8192 |
| 2048 (2)   | 4096-16384 (1GB increments) |
| 4096 (4)   | 8192-30720 (1GB increments) |

### Outputs

| Output | Description |
|--------|-------------|
| `repo_name` | ECR repository name |
| `image_tag` | Latest image tag from ECR |

### Best Practices

1. **IAM Roles**: Separate task and execution roles for least privilege
2. **Logging**: Always configure CloudWatch Logs
3. **Secrets**: Use Secrets Manager for sensitive data
4. **Resource Limits**: Set CPU and memory limits appropriately
5. **Fargate**: Use for serverless container execution

---

## ec2_user_data

### Overview

The `ec2_user_data` module generates standardized cloud-init user data scripts for EC2 instances including EBS mounting and SSM agent.

### Key Features

- **EBS Volume Mounting**: Automatic detection and mounting of /dev/xvdf or /dev/nvme1n1
- **SSM Agent**: Systems Manager agent installation
- **Custom Scripts**: Support for additional user data

### Usage Example

```hcl
module "user_data" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_user_data?ref=main"

  custom_user_data = <<-EOF
    #!/bin/bash
    # Application-specific initialization
    yum install -y docker
    systemctl start docker
    systemctl enable docker
  EOF
}

resource "aws_instance" "app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.medium"

  user_data = module.user_data.user_data_content

  # ... other configuration
}
```

### Outputs

| Output | Description |
|--------|-------------|
| `user_data_content` | Base64-encoded cloud-init configuration |

### Included Scripts

1. **EBS Volume Mount** (`/data`):
   ```bash
   - Detects device (xvdf or nvme1n1)
   - Creates filesystem if needed
   - Mounts to /data
   - Adds to /etc/fstab
   ```

2. **SSM Agent Installation**:
   ```bash
   - Downloads from AWS
   - Installs RPM/DEB
   - Enables service
   ```

### Best Practices

1. Keep custom user data scripts idempotent
2. Test user data in dev before production
3. Check logs in `/var/log/cloud-init-output.log`
4. Use ec2_scalable module which has built-in user data support

### Related Modules

- **ec2_scalable**: Has built-in user data generation with more features
- **vpc_module**: Provides network infrastructure for EC2 instances
