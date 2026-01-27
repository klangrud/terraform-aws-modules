# Transfer Family SFTP Secret

Creates and manages SFTP user credentials in AWS Secrets Manager for use with AWS Transfer Family. Automatically generates secure passwords and supports rotation.

## Features

- Secure password generation with configurable length
- AWS Secrets Manager integration
- Password rotation via version tracking
- IP allowlist support for enhanced security
- Compatible with AWS Transfer Family managed authentication
- Uses only Transfer Family-allowed special characters

## Usage

### Basic SFTP Secret

```hcl
module "transfer_family_sftp_secret" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/transfer_family_sftp_secret?ref=main"

  secret_name    = "sftp-server-123/partner-user"
  role_arn       = aws_iam_role.sftp_user.arn
  home_directory = "/my-bucket/uploads"
}
```

### With IP Restrictions

```hcl
module "transfer_family_sftp_secret" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/transfer_family_sftp_secret?ref=main"

  secret_name         = "sftp-server-123/vendor-user"
  role_arn            = aws_iam_role.sftp_user.arn
  home_directory      = "/my-bucket/vendor-uploads"
  accepted_ip_network = "203.0.113.0/24"

  tags = {
    Environment = "Production"
    Vendor      = "Acme Corp"
  }
}
```

### Password Rotation

To rotate the password, change the `password_rotation` value:

```hcl
module "transfer_family_sftp_secret" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/transfer_family_sftp_secret?ref=main"

  secret_name    = "sftp-server-123/partner-user"
  role_arn       = aws_iam_role.sftp_user.arn
  home_directory = "/my-bucket/uploads"

  # Change this value to trigger rotation
  password_rotation = "2024-06-15"  # Update to current date
}
```

### Complete Transfer Family Setup

```hcl
# 1. Create IAM role for SFTP user
resource "aws_iam_role" "sftp_user" {
  name = "sftp-partner-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "transfer.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

# 2. Attach S3 access policy
resource "aws_iam_role_policy" "sftp_user" {
  name = "sftp-s3-access"
  role = aws_iam_role.sftp_user.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:ListBucket"]
        Resource = ["arn:aws:s3:::my-sftp-bucket"]
      },
      {
        Effect   = "Allow"
        Action   = ["s3:GetObject", "s3:PutObject", "s3:DeleteObject"]
        Resource = ["arn:aws:s3:::my-sftp-bucket/*"]
      }
    ]
  })
}

# 3. Create SFTP secret
module "transfer_family_sftp_secret" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/transfer_family_sftp_secret?ref=main"

  secret_name         = "${aws_transfer_server.main.id}/partner-user"
  role_arn            = aws_iam_role.sftp_user.arn
  home_directory      = "/my-sftp-bucket/partner"
  accepted_ip_network = "198.51.100.0/24"
  password_rotation   = "2024-01-01"

  tags = {
    Environment = "Production"
  }
}

# 4. Reference in Transfer Family (if using custom identity provider)
# The secret ARN can be used with Lambda-based authentication
output "secret_arn" {
  value = module.transfer_family_sftp_secret.secret_arn
}
```

## How It Works

This module creates a Secrets Manager secret with the following JSON structure:

```json
{
  "Role": "arn:aws:iam::123456789012:role/sftp-user-role",
  "HomeDirectory": "/bucket-name/folder",
  "AcceptedIpNetwork": "0.0.0.0/0",
  "Password": "auto-generated-password"
}
```

This format is compatible with AWS Transfer Family's [Lambda-based custom identity provider](https://docs.aws.amazon.com/transfer/latest/userguide/custom-identity-provider-users.html).

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 5.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | >= 3.5.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 5.0 |
| <a name="provider_random"></a> [random](#provider\_random) | >= 3.5.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_secretsmanager_secret.sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.sftp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [random_password.sftp](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_accepted_ip_network"></a> [accepted\_ip\_network](#input\_accepted\_ip\_network) | CIDR block of allowed source IPs. Use 0.0.0.0/0 to allow all IPs. | `string` | `"0.0.0.0/0"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description for the Secrets Manager secret | `string` | `"SFTP user credentials for AWS Transfer Family"` | no |
| <a name="input_home_directory"></a> [home\_directory](#input\_home\_directory) | Home directory path for the SFTP user (e.g., /bucket-name/folder) | `string` | n/a | yes |
| <a name="input_password_length"></a> [password\_length](#input\_password\_length) | Length of the generated password | `number` | `16` | no |
| <a name="input_password_rotation"></a> [password\_rotation](#input\_password\_rotation) | Change this value to trigger password rotation (e.g., use a date like 2024-01-15) | `string` | `"initial"` | no |
| <a name="input_role_arn"></a> [role\_arn](#input\_role\_arn) | ARN of the IAM role that grants SFTP user access to S3 | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | Name for the Secrets Manager secret. Recommend format: {transfer-server-id}/{username} | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the secret | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | ARN of the Secrets Manager secret |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | ID of the Secrets Manager secret |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Name of the Secrets Manager secret |
<!-- END_TF_DOCS -->
