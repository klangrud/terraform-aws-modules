# EC2 Scalable Module

A flexible, secure, and scalable EC2 module that supports single or multiple instances with dynamic EBS volume management, automatic filesystem mounting, and best-practice security configurations.

## Features

- **Scalable Architecture**: Deploy 1 to 100 EC2 instances with a single module call
- **Automatic EBS Management**: Dynamically create, attach, format, and mount EBS volumes
- **Secure by Default**:
  - Uses secure AMI (Amazon Linux 2023) by default
  - IMDSv2 enforced
  - Encrypted EBS volumes
  - API termination protection enabled
- **Cost-Effective**: Defaults to `t3a.medium` for optimal price/performance
- **Automated Security Updates**: Apply security patches on first boot
- **Built-in Monitoring**: SSM Agent installation
- **Flexible Storage**: Optional `/data` volume + unlimited additional EBS volumes
- **Multi-Subnet Distribution**: Instances distributed across provided subnets for HA
- **IAM Integration**: Auto-creates IAM instance profile with SSM permissions

## Usage Examples

### Example 1: Single Instance with Default Settings

```hcl
module "ec2_basic" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=v1.0.0"

  project_name = "my-app"
  env_short    = "prod"

  vpc_id      = "vpc-12345678"
  subnet_ids  = ["subnet-abcd1234"]
  ec2_key_pair = "my-keypair"

  tags = {
    Owner = "data-engineering"
    Cost  = "project-x"
  }
}
```

### Example 2: Single Instance with /data Volume

```hcl
module "ec2_with_data" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=v1.0.0"

  project_name = "research-hub"
  env_short    = "prod"

  vpc_id       = "vpc-12345678"
  subnet_ids   = ["subnet-abcd1234"]
  ec2_key_pair = "research-keypair"

  # Enable /data volume
  enable_data_volume = true
  data_volume_size   = 500  # 500 GB

  # Larger root volume
  root_block_device = {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 100
    iops        = 3000
    throughput  = 125
  }

  tags = {
    Application = "research-platform"
    Environment = "production"
  }
}
```

### Example 3: Single Instance with Multiple Custom EBS Volumes

```hcl
module "ec2_multi_volume" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=v1.0.0"

  project_name = "database-server"
  env_short    = "prod"

  vpc_id       = "vpc-12345678"
  subnet_ids   = ["subnet-abcd1234"]
  ec2_key_pair = "db-keypair"

  instance_type = "m5.xlarge"

  # Multiple volumes for database workloads
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
      iops        = 3000
      throughput  = 125
      filesystem  = "ext4"
    }
  ]

  # Additional IAM permissions for backup access
  additional_iam_policies = [
    "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  ]
}
```

### Example 4: Multiple Instances Across Subnets (High Availability)

```hcl
module "ec2_cluster" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=v1.0.0"

  project_name   = "app-cluster"
  env_short      = "prod"
  instance_count = 3  # Deploy 3 instances

  vpc_id = "vpc-12345678"
  subnet_ids = [
    "subnet-abcd1234",  # us-east-1a
    "subnet-efgh5678",  # us-east-1b
    "subnet-ijkl9012"   # us-east-1c
  ]
  ec2_key_pair = "cluster-keypair"

  instance_type = "t3a.large"

  # Shared /data volume on each instance
  enable_data_volume = true
  data_volume_size   = 200

  # Custom security group rules
  allowed_cidr_blocks = ["10.0.0.0/8"]
  allowed_ssh_cidr_blocks = ["10.10.0.0/16"]
}
```

### Example 5: Advanced Configuration with Custom User Data

```hcl
module "ec2_custom" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_scalable?ref=v1.0.0"

  project_name = "custom-app"
  env_short    = "prod"

  vpc_id       = "vpc-12345678"
  subnet_ids   = ["subnet-abcd1234"]
  ec2_key_pair = "custom-keypair"

  # Custom AMI (must be Amazon Linux 2023 compatible)
  ami_id = "ami-custom12345"

  # Disable default agents
  install_ssm_agent      = false

  # Custom user data script
  custom_user_data_parts = [
    {
      content_type = "text/x-shellscript"
      filename     = "50-install-docker.sh"
      content      = <<-EOF
        #!/bin/bash
        set -e
        echo "Installing Docker..."
        yum install -y docker
        systemctl enable docker
        systemctl start docker
        usermod -aG docker ec2-user
      EOF
    }
  ]

  # Use external IAM instance profile
  iam_instance_profile        = "my-custom-profile"
  create_iam_instance_profile = false

  # Use external security group
  security_group_ids   = ["sg-existing123"]
  create_security_group = false
}
```

## Inputs

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| `project_name` | Name of the project or application | `string` |
| `env_short` | Short form of the environment (e.g., dev, prod) | `string` |
| `vpc_id` | VPC ID where EC2 instances will reside | `string` |
| `subnet_ids` | List of subnet IDs for EC2 placement | `list(string)` |
| `ec2_key_pair` | EC2 Key Pair name | `string` |

### Optional Variables

#### Instance Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `ami_id` | AMI ID for EC2 instances | `string` | `ami-0017468bf94789869` (Amazon Linux 2023) |
| `instance_type` | EC2 instance type | `string` | `t3a.medium` |
| `instance_count` | Number of instances to create | `number` | `1` |
| `enable_detailed_monitoring` | Enable detailed CloudWatch monitoring | `bool` | `false` |
| `disable_api_termination` | Enable termination protection | `bool` | `true` |

#### Storage Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `root_block_device` | Root volume configuration | `object` | 30 GB gp3 encrypted |
| `enable_data_volume` | Enable default /data volume | `bool` | `false` |
| `data_volume_size` | Size of /data volume in GB | `number` | `100` |
| `additional_ebs_volumes` | List of additional EBS volumes | `list(object)` | `[]` |

#### Network Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `associate_public_ip_address` | Assign public IP | `bool` | `false` |
| `security_group_ids` | External security group IDs | `list(string)` | `[]` |
| `create_security_group` | Create default security group | `bool` | `true` |
| `allowed_cidr_blocks` | CIDRs allowed access | `list(string)` | `[]` |
| `allowed_ssh_cidr_blocks` | CIDRs allowed SSH access | `list(string)` | `[]` |

#### IAM Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `iam_instance_profile` | Existing IAM instance profile name | `string` | `null` |
| `create_iam_instance_profile` | Create IAM instance profile | `bool` | `true` |
| `additional_iam_policies` | Additional IAM policy ARNs | `list(string)` | `[]` |

#### User Data Configuration

| Name | Description | Type | Default |
|------|-------------|------|---------|
| `enable_security_updates` | Apply security updates on boot | `bool` | `true` |
| `install_ssm_agent` | Install AWS SSM Agent | `bool` | `true` |
| `custom_user_data_parts` | Custom cloud-init parts | `list(object)` | `[]` |

## Outputs

| Name | Description |
|------|-------------|
| `instance_ids` | List of EC2 instance IDs |
| `instance_private_ips` | List of private IP addresses |
| `instance_public_ips` | List of public IP addresses (if applicable) |
| `instance_arns` | List of EC2 instance ARNs |
| `security_group_id` | Security group ID (if created) |
| `iam_role_arn` | IAM role ARN (if created) |
| `iam_role_name` | IAM role name (if created) |
| `iam_instance_profile_arn` | IAM instance profile ARN (if created) |
| `iam_instance_profile_name` | IAM instance profile name (if created) |
| `ebs_volume_ids` | Map of EBS volume IDs |
| `ebs_volume_arns` | Map of EBS volume ARNs |
| `instance_details` | Detailed information about each instance |

## EBS Volume Auto-Mounting

The module automatically handles:
1. **Device Detection**: Detects both classic (xvdf) and NVMe (nvme1n1) device naming
2. **Filesystem Creation**: Creates ext4 filesystem if not present
3. **Mounting**: Mounts volumes to specified mount points
4. **Persistence**: Adds UUID-based fstab entries for persistence across reboots
5. **Error Handling**: Includes retry logic and detailed logging

### Supported Filesystems

- `ext4` (default)
- `xfs`
- `ext3`

### Device Name Mapping

The module handles NVMe device name translation:

| Requested Device | Actual Device (NVMe) |
|------------------|----------------------|
| `/dev/sdf` | `/dev/nvme1n1` |
| `/dev/sdg` | `/dev/nvme2n1` |
| `/dev/sdh` | `/dev/nvme3n1` |
| `/dev/sdi` | `/dev/nvme4n1` |

## Security Features

### Default Security Posture

- **IMDSv2 Enforced**: Instance metadata service v2 required
- **Encrypted Volumes**: All EBS volumes encrypted by default
- **Termination Protection**: Enabled by default
- **Security Updates**: Applied on first boot
- **SSM Access**: No SSH bastion needed (uses AWS Systems Manager)
- **No Public IPs**: Private by default

### IAM Permissions

The auto-created IAM role includes:
- `AmazonSSMManagedInstanceCore` - SSM access
- `CloudWatchAgentServerPolicy` - CloudWatch logging
- Custom policies can be added via `additional_iam_policies`

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
cd test/ec2_scalable

# Unit tests only
go test -v -tags=unit ./... -timeout 10m

# Integration tests only
go test -v -tags=integration ./... -timeout 30m

# Specific test
go test -v -tags=unit -run TestInstanceConfiguration ./... -timeout 10m
```

### Test Fixtures

Test fixtures are located in `test/ec2_scalable/fixtures/`. The fixtures demonstrate module configurations:

- **basic/**: Basic EC2 instance deployment

You can use these fixtures as reference examples for your own implementations.

### Related Testing Documentation

For comprehensive testing information, see:
- [Testing Guide](../../docs/TESTING.md) - Full testing documentation for all modules

## Best Practices

1. **Use the Default AMI**: `ami-0017468bf94789869` is vetted for security
2. **Enable `/data` Volume**: Separate data from the root volume
3. **Use Multiple Subnets**: For high availability across AZs
4. **Tag Resources**: Always include Owner, Cost Center, Application tags
5. **Monitor Costs**: Use `t3a` instances for cost savings over `t3`
6. **Version Module Calls**: Always specify `?ref=vX.Y.Z` in source
7. **Test in Dev First**: Validate configurations before prod deployment
8. **Test Locally**: Use the provided test suite to validate your configuration

## Troubleshooting

### EBS Volume Not Mounting

Check cloud-init logs:
```bash
sudo cat /var/log/cloud-init-output.log
```

Verify device is attached:
```bash
lsblk
```

### SSM Agent Not Connecting

Verify IAM instance profile:
```bash
aws ec2 describe-instances --instance-ids i-xxxxx --query 'Reservations[0].Instances[0].IamInstanceProfile'
```

Check SSM agent status:
```bash
sudo systemctl status amazon-ssm-agent
```

### Security Updates Failed

Check cloud-init logs for errors:
```bash
sudo grep -A 20 "security-updates" /var/log/cloud-init-output.log
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 5.0 |
| cloudinit | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 5.0 |
| cloudinit | >= 2.0 |

## License

Open source Terraform modules for AWS infrastructure

## Authors

Created and maintained by the the community

## Changelog

### v1.0.0 (2025-12-03)
- Initial release
- Support for single and multiple EC2 instances
- Automatic EBS volume creation, attachment, and mounting
- Security updates on first boot
- SSM agent installation
- Secure defaults (IMDSv2, encryption, termination protection)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.24.0 |
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | 2.3.7 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ebs_volume.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ebs_volume) | resource |
| [aws_iam_instance_profile.ec2_profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.ec2_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.ssm_s3_encryption_read](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_iam_role_policy_attachment.additional_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.cloudwatch_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ssm_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_instance.ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_security_group.ec2_sg](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_volume_attachment.additional](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/volume_attachment) | resource |
| [aws_subnet.selected](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [cloudinit_config.user_data](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_ebs_volumes"></a> [additional\_ebs\_volumes](#input\_additional\_ebs\_volumes) | List of additional EBS volumes to create and mount. Each volume requires device\_name, mount\_point, volume\_size, and optionally volume\_type, iops, throughput, and encrypted. | <pre>list(object({<br>    device_name = string<br>    mount_point = string<br>    volume_size = number<br>    volume_type = optional(string, "gp3")<br>    iops        = optional(number, 3000)<br>    throughput  = optional(number, 125)<br>    encrypted   = optional(bool, true)<br>    filesystem  = optional(string, "ext4")<br>  }))</pre> | `[]` | no |
| <a name="input_additional_iam_policies"></a> [additional\_iam\_policies](#input\_additional\_iam\_policies) | List of additional IAM policy ARNs to attach to the instance profile. | `list(string)` | `[]` | no |
| <a name="input_allowed_cidr_blocks"></a> [allowed\_cidr\_blocks](#input\_allowed\_cidr\_blocks) | CIDR blocks allowed to access the EC2 instances (used if create\_security\_group is true). | `list(string)` | `[]` | no |
| <a name="input_allowed_ssh_cidr_blocks"></a> [allowed\_ssh\_cidr\_blocks](#input\_allowed\_ssh\_cidr\_blocks) | CIDR blocks allowed SSH access (port 22) to the EC2 instances. | `list(string)` | `[]` | no |
| <a name="input_ami_id"></a> [ami\_id](#input\_ami\_id) | Amazon Machine Image (AMI) ID for the EC2 instance. Defaults to secure Amazon Linux 2023 AMI. | `string` | `"ami-0017468bf94789869"` | no |
| <a name="input_associate_public_ip_address"></a> [associate\_public\_ip\_address](#input\_associate\_public\_ip\_address) | Associate a public IP address with the EC2 instance. | `bool` | `false` | no |
| <a name="input_create_iam_instance_profile"></a> [create\_iam\_instance\_profile](#input\_create\_iam\_instance\_profile) | If true, creates an IAM instance profile with SSM permissions. | `bool` | `true` | no |
| <a name="input_create_security_group"></a> [create\_security\_group](#input\_create\_security\_group) | If true, creates a default security group for the EC2 instances. | `bool` | `true` | no |
| <a name="input_custom_user_data_parts"></a> [custom\_user\_data\_parts](#input\_custom\_user\_data\_parts) | List of custom cloud-init user data parts to include. Each part should have content\_type, filename, and content. | <pre>list(object({<br>    content_type = string<br>    filename     = string<br>    content      = string<br>  }))</pre> | `[]` | no |
| <a name="input_data_volume_size"></a> [data\_volume\_size](#input\_data\_volume\_size) | Size in GB for the default /data volume (only used if enable\_data\_volume is true). | `number` | `100` | no |
| <a name="input_disable_api_termination"></a> [disable\_api\_termination](#input\_disable\_api\_termination) | If true, enables EC2 Instance Termination Protection. | `bool` | `true` | no |
| <a name="input_ec2_key_pair"></a> [ec2\_key\_pair](#input\_ec2\_key\_pair) | EC2 Key Pair Name (must exist in the region). | `string` | n/a | yes |
| <a name="input_enable_data_volume"></a> [enable\_data\_volume](#input\_enable\_data\_volume) | Enable a default /data volume mounted at /data. | `bool` | `false` | no |
| <a name="input_enable_detailed_monitoring"></a> [enable\_detailed\_monitoring](#input\_enable\_detailed\_monitoring) | Enable detailed CloudWatch monitoring for the EC2 instance (incurs additional costs). | `bool` | `false` | no |
| <a name="input_enable_security_updates"></a> [enable\_security\_updates](#input\_enable\_security\_updates) | Apply security updates on first boot. | `bool` | `true` | no |
| <a name="input_env_short"></a> [env\_short](#input\_env\_short) | Short form of the environment (e.g., dev, test, prod). | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Full environment name (legacy compatibility). | `string` | `""` | no |
| <a name="input_iam_instance_profile"></a> [iam\_instance\_profile](#input\_iam\_instance\_profile) | IAM Instance Profile Name for the EC2 instance. If not provided, a default profile with SSM permissions will be created. | `string` | `null` | no |
| <a name="input_install_ssm_agent"></a> [install\_ssm\_agent](#input\_install\_ssm\_agent) | Install AWS SSM Agent on first boot. | `bool` | `true` | no |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | Number of EC2 instances to create. Set to 1 for single instance, or higher for scalability. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | EC2 Instance Type. Defaults to t3a.medium for cost-effective performance. | `string` | `"t3a.medium"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names. If not provided, defaults to project\_name-env\_short. | `string` | `""` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project or application (e.g., research-hub). | `string` | n/a | yes |
| <a name="input_root_block_device"></a> [root\_block\_device](#input\_root\_block\_device) | Configuration for the root block device (primary storage). | <pre>object({<br>    encrypted   = bool<br>    volume_type = string<br>    volume_size = number<br>    iops        = optional(number)<br>    throughput  = optional(number)<br>  })</pre> | <pre>{<br>  "encrypted": true,<br>  "iops": 3000,<br>  "throughput": 125,<br>  "volume_size": 30,<br>  "volume_type": "gp3"<br>}</pre> | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of security group IDs to attach to the EC2 instances. If empty, a default security group will be created. | `list(string)` | `[]` | no |
| <a name="input_subnet_count"></a> [subnet\_count](#input\_subnet\_count) | Optional explicit number of subnets. If set, avoids count depending on unknown subnet\_ids length. | `number` | `null` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of subnet IDs for EC2 placement. If instance\_count > 1, instances will be distributed across subnets. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | AWS Tags that can be applied to a resource that accepts them. | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID where the EC2 instance will reside. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ebs_volume_arns"></a> [ebs\_volume\_arns](#output\_ebs\_volume\_arns) | Map of EBS volume ARNs (key format: instance-volume) |
| <a name="output_ebs_volume_ids"></a> [ebs\_volume\_ids](#output\_ebs\_volume\_ids) | Map of EBS volume IDs (key format: instance-volume) |
| <a name="output_iam_instance_profile_arn"></a> [iam\_instance\_profile\_arn](#output\_iam\_instance\_profile\_arn) | IAM instance profile ARN created for the EC2 instances (if created) |
| <a name="output_iam_instance_profile_name"></a> [iam\_instance\_profile\_name](#output\_iam\_instance\_profile\_name) | IAM instance profile name created for the EC2 instances (if created) |
| <a name="output_iam_role_arn"></a> [iam\_role\_arn](#output\_iam\_role\_arn) | IAM role ARN created for the EC2 instances (if created) |
| <a name="output_iam_role_name"></a> [iam\_role\_name](#output\_iam\_role\_name) | IAM role name created for the EC2 instances (if created) |
| <a name="output_instance_arns"></a> [instance\_arns](#output\_instance\_arns) | List of EC2 instance ARNs |
| <a name="output_instance_details"></a> [instance\_details](#output\_instance\_details) | Detailed information about each EC2 instance |
| <a name="output_instance_ids"></a> [instance\_ids](#output\_instance\_ids) | List of EC2 instance IDs |
| <a name="output_instance_private_ips"></a> [instance\_private\_ips](#output\_instance\_private\_ips) | List of private IP addresses for the EC2 instances |
| <a name="output_instance_public_ips"></a> [instance\_public\_ips](#output\_instance\_public\_ips) | List of public IP addresses for the EC2 instances (if applicable) |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | Security group ID created for the EC2 instances (if created) |
<!-- END_TF_DOCS -->
