# IAM Password Policy

Configures the AWS account-wide IAM password policy with secure defaults. All settings are customizable to meet different compliance requirements.

## Features

- Fully configurable password requirements
- Secure defaults (14+ chars, complexity, 90-day rotation)
- Works with any compliance framework (HIPAA, HITRUST, SOC2, PCI-DSS, etc.)
- Simple single-resource module

## Usage

### Basic Usage (Secure Defaults)

```hcl
module "iam_password_policy" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"
}
```

### HIPAA/HITRUST Compliant (Default Settings)

The defaults are designed to meet HIPAA and HITRUST requirements:

```hcl
module "iam_password_policy" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"

  # These are the defaults - shown for clarity
  minimum_password_length   = 14
  require_lowercase_characters = true
  require_uppercase_characters = true
  require_numbers              = true
  require_symbols              = true
  max_password_age             = 90
  password_reuse_prevention    = 24
}
```

### SOC2/PCI-DSS Configuration

```hcl
module "iam_password_policy" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"

  minimum_password_length   = 12
  max_password_age          = 90
  password_reuse_prevention = 12
}
```

### Relaxed Policy (Development Environments)

```hcl
module "iam_password_policy" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"

  minimum_password_length   = 8
  require_symbols           = false
  max_password_age          = 0  # No expiration
  password_reuse_prevention = 0  # No reuse prevention
}
```

### Strict Enterprise Policy

```hcl
module "iam_password_policy" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"

  minimum_password_length   = 16
  max_password_age          = 60
  password_reuse_prevention = 24
  hard_expiry               = true  # Requires admin to reset expired passwords
}
```

### Multi-Account Deployment

```hcl
module "password_policy_prod" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"

  providers = {
    aws = aws.production
  }

  minimum_password_length = 16
  max_password_age        = 60
}

module "password_policy_dev" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/iam_password_policy?ref=main"

  providers = {
    aws = aws.development
  }

  minimum_password_length = 12
  max_password_age        = 0  # No expiration in dev
}
```

## Compliance Reference

| Framework | Min Length | Complexity | Max Age | Reuse Prevention |
|-----------|------------|------------|---------|------------------|
| HIPAA | 8+ | Recommended | 90 days | Recommended |
| HITRUST | 14+ | Required | 90 days | 24 passwords |
| SOC2 | 8+ | Recommended | 90 days | Recommended |
| PCI-DSS | 12+ | Required | 90 days | 4 passwords |
| NIST 800-63B | 8+ | Not required | Not required | Check against breach lists |

**Note**: NIST 800-63B (2017) recommends against mandatory password rotation and complexity rules. Consider your specific compliance requirements.

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
| [aws_iam_account_password_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_account_password_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_users_to_change_password"></a> [allow\_users\_to\_change\_password](#input\_allow\_users\_to\_change\_password) | Allow IAM users to change their own passwords. | `bool` | `true` | no |
| <a name="input_hard_expiry"></a> [hard\_expiry](#input\_hard\_expiry) | Prevent users from resetting expired passwords without admin help. | `bool` | `false` | no |
| <a name="input_max_password_age"></a> [max\_password\_age](#input\_max\_password\_age) | Maximum age (in days) before password expires. Set to 0 to disable expiration. | `number` | `90` | no |
| <a name="input_minimum_password_length"></a> [minimum\_password\_length](#input\_minimum\_password\_length) | Minimum length for IAM user passwords. AWS minimum is 6, recommended is 14+. | `number` | `14` | no |
| <a name="input_password_reuse_prevention"></a> [password\_reuse\_prevention](#input\_password\_reuse\_prevention) | Number of previous passwords that cannot be reused. Set to 0 to disable. | `number` | `24` | no |
| <a name="input_require_lowercase_characters"></a> [require\_lowercase\_characters](#input\_require\_lowercase\_characters) | Require at least one lowercase letter. | `bool` | `true` | no |
| <a name="input_require_numbers"></a> [require\_numbers](#input\_require\_numbers) | Require at least one number. | `bool` | `true` | no |
| <a name="input_require_symbols"></a> [require\_symbols](#input\_require\_symbols) | Require at least one special character. | `bool` | `true` | no |
| <a name="input_require_uppercase_characters"></a> [require\_uppercase\_characters](#input\_require\_uppercase\_characters) | Require at least one uppercase letter. | `bool` | `true` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
