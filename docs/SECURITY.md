# Security & Access Control Modules

Modules for IAM, identity federation, SFTP access, and credential management.

## Table of Contents

- [identity_provider](#identity_provider)
- [iam_password_policy](#iam_password_policy)
- [transfer_family_sftp_secret](#transfer_family_sftp_secret)

---

## identity_provider

### Overview

Integrates AWS with Okta for SAML-based SSO authentication.

### Resources Created

- **SAML Provider**: Okta identity provider
- **Okta SSO User**: Programmatic access for Okta
- **IAM Policy**: Allows listing roles for role selection

### Usage Example

```hcl
module "okta_idp" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/identity_provider?ref=main"

  env = "production"
  saml_metadata_document = file("${path.module}/okta-metadata.xml")

  tags = {
    Provider = "Okta"
  }
}
```

### SAML Metadata

Obtain from Okta admin console: **Applications → Your AWS App → Sign On → View Setup Instructions**

---

## iam_password_policy

### Overview

Enforces compliant password policy across the AWS account.

### Policy Requirements

- **Minimum Length**: 14 characters
- **Complexity**: Requires lowercase, uppercase, numbers, symbols
- **Max Age**: 90 days
- **Reuse Prevention**: 24 passwords
- **User Control**: Users can change own passwords

### Usage Example

```hcl
module "password_policy" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"
}
```

**Note**: This is an account-wide setting. Only deploy once per account.

---

## transfer_family_sftp_secret

### Overview

Creates Secrets Manager secret with SFTP credentials for Transfer Family authentication.

### Secret Format

```json
{
  "Password": "randomly-generated-32-char-password",
  "Role": "arn:aws:iam::123456789012:role/transfer-role",
  "HomeDirectory": "/bucket/path",
  "PublicKey": "ssh-rsa AAAA...",
  "AcceptedIpNetwork": "203.0.113.0/24"
}
```

### Usage Example

```hcl
module "sftp_credentials" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/transfer_family_sftp_secret?ref=main"

  secret_name        = "transfer-partner"
  role_arn           = aws_iam_role.transfer_role.arn
  home_directory     = "/bucket/partner/home"
  accepted_ip_network = "203.0.113.0/24"

  tags = {
    Purpose = "sftp-auth"
  }
}
```

### Password Rotation

Increment `password_rotation` variable to regenerate password:

```hcl
module "sftp_credentials" {
  # ... other config
  password_rotation = 2  # Increment to rotate
}
```

---

## Best Practices

1. **SSO**: Use Okta SSO for all human access via identity_provider module
2. **Least Privilege**: Assign users to appropriate role-based groups in Okta
3. **IP Restrictions**: Always set IP restrictions for SFTP accounts
4. **Password Rotation**: Implement regular SFTP password rotation
5. **Monitoring**: Enable CloudWatch logging for Transfer Family
6. **MFA**: Enforce MFA through Okta policies
