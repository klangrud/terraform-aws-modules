# EC2 User Data Module

A Terraform module that generates cloud-init user data for EC2 instances with automated EBS volume mounting and SSM Agent installation.

## Features

- Automatic EBS volume mounting at `/data`
- Amazon SSM Agent installation and enablement
- Support for custom user data scripts
- Multi-part MIME user data format

## Usage

### Basic User Data (Default Scripts Only)

```hcl
module "user_data" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_user_data?ref=main"
}

resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t3.medium"
  user_data     = module.user_data.user_data_content

  # ... other instance configuration
}
```

### User Data with Custom Scripts

```hcl
module "user_data_custom" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/ec2_user_data?ref=main"

  custom_user_data = {
    install_docker = {
      content_type = "text/x-shellscript"
      filename     = "install-docker.sh"
      content      = <<-EOF
        #!/bin/bash
        yum install -y docker
        systemctl enable docker
        systemctl start docker
      EOF
    }
    configure_app = {
      content_type = "text/x-shellscript"
      filename     = "configure-app.sh"
      content      = <<-EOF
        #!/bin/bash
        echo "APP_ENV=production" > /etc/app.conf
      EOF
    }
  }
}

resource "aws_instance" "app" {
  ami           = "ami-12345678"
  instance_type = "t3.medium"
  user_data     = module.user_data_custom.user_data_content

  # ... other instance configuration
}
```

## Default Scripts Included

1. **EBS Volume Mounting** (`mount-ebs.sh`):
   - Automatically detects and mounts EBS volume at `/data`
   - Formats volume with ext4 if not already formatted
   - Adds persistent fstab entry using UUID

2. **SSM Agent Installation** (`amazon-ssm-agent-install`):
   - Installs AWS Systems Manager Agent
   - Enables and starts the agent service
   - Allows SSH-less access to EC2 instances

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_cloudinit"></a> [cloudinit](#requirement\_cloudinit) | >= 2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_cloudinit"></a> [cloudinit](#provider\_cloudinit) | >= 2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [cloudinit_config.user_data](https://registry.terraform.io/providers/hashicorp/cloudinit/latest/docs/data-sources/config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_custom_user_data"></a> [custom\_user\_data](#input\_custom\_user\_data) | n/a | `map` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_user_data_content"></a> [user\_data\_content](#output\_user\_data\_content) | n/a |
<!-- END_TF_DOCS -->
