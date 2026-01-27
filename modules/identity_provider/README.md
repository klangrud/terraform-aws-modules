# Identity Provider (SAML 2.0)

Configures a SAML 2.0 identity provider for AWS account SSO access. Works with any SAML-compatible IdP including Okta, Azure AD, Google Workspace, OneLogin, and others.

## Features

- SAML 2.0 identity provider configuration
- Works with any SAML-compatible IdP
- Optional IAM user for role discovery (required by some IdPs like Okta)
- Environment-aware naming for multi-account setups
- Outputs provider ARN for use in IAM role trust policies

## Usage

### Basic Setup (Azure AD, Google Workspace)

```hcl
module "identity_provider" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/identity_provider?ref=main"

  env                    = "prod"
  provider_name          = "azure-ad"
  saml_metadata_document = file("azure-ad-metadata.xml")

  tags = {
    Environment = "Production"
    ManagedBy   = "Terraform"
  }
}
```

### Okta Setup (with Role Discovery)

Okta requires an IAM user to dynamically discover available roles:

```hcl
module "identity_provider" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/identity_provider?ref=main"

  env                        = "prod"
  provider_name              = "okta"
  saml_metadata_document     = file("okta-metadata.xml")
  create_role_discovery_user = true
  role_discovery_user_name   = "OktaSSOUser"

  tags = {
    Environment = "Production"
  }
}

# Use the outputs to configure Okta
output "okta_config" {
  value = {
    provider_arn = module.identity_provider.saml_provider_arn
    user_name    = module.identity_provider.role_discovery_user_name
  }
}
```

### Multi-Account Deployment

```hcl
module "idp_prod" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/identity_provider?ref=main"

  providers = {
    aws = aws.production
  }

  env                    = "prod"
  provider_name          = "corporate-sso"
  saml_metadata_document = file("sso-metadata.xml")
}

module "idp_dev" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/identity_provider?ref=main"

  providers = {
    aws = aws.development
  }

  env                    = "dev"
  provider_name          = "corporate-sso"
  saml_metadata_document = file("sso-metadata.xml")
}
```

### Creating IAM Roles that Trust the IdP

```hcl
module "identity_provider" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/identity_provider?ref=main"

  env                    = "prod"
  provider_name          = "corporate-idp"
  saml_metadata_document = file("idp-metadata.xml")
}

# Create an admin role that trusts the IdP
resource "aws_iam_role" "admin" {
  name = "AdminRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = module.identity_provider.saml_provider_arn
        }
        Action = "sts:AssumeRoleWithSAML"
        Condition = {
          StringEquals = {
            "SAML:aud" = "https://signin.aws.amazon.com/saml"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "admin" {
  role       = aws_iam_role.admin.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}
```

## Supported Identity Providers

| IdP | Role Discovery User | Notes |
|-----|---------------------|-------|
| Okta | Required | Set `create_role_discovery_user = true` |
| Azure AD | Not required | Uses Azure AD app registration |
| Google Workspace | Not required | Uses Google Cloud Identity |
| OneLogin | Optional | Can use role discovery or manual config |
| AWS IAM Identity Center | N/A | Use AWS SSO instead of this module |

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
| [aws_iam_policy.role_discovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_saml_provider.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_saml_provider) | resource |
| [aws_iam_user.role_discovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user) | resource |
| [aws_iam_user_policy_attachment.role_discovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_user_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_role_discovery_user"></a> [create\_role\_discovery\_user](#input\_create\_role\_discovery\_user) | Create an IAM user for IdP role discovery (required for Okta, optional for others). | `bool` | `false` | no |
| <a name="input_env"></a> [env](#input\_env) | Environment name (e.g., prod, dev, staging). Used in resource naming. | `string` | n/a | yes |
| <a name="input_provider_name"></a> [provider\_name](#input\_provider\_name) | Name for the SAML identity provider. Will be suffixed with environment. | `string` | `"saml-idp"` | no |
| <a name="input_role_discovery_user_name"></a> [role\_discovery\_user\_name](#input\_role\_discovery\_user\_name) | Name for the IAM user used by IdP for role discovery. Only used if create\_role\_discovery\_user is true. | `string` | `"SSOServiceUser"` | no |
| <a name="input_saml_metadata_document"></a> [saml\_metadata\_document](#input\_saml\_metadata\_document) | SAML Metadata XML document from your identity provider (Okta, Azure AD, Google Workspace, etc.) | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_discovery_user_arn"></a> [role\_discovery\_user\_arn](#output\_role\_discovery\_user\_arn) | ARN of the IAM user for role discovery (if created) |
| <a name="output_role_discovery_user_name"></a> [role\_discovery\_user\_name](#output\_role\_discovery\_user\_name) | Name of the IAM user for role discovery (if created) |
| <a name="output_saml_provider_arn"></a> [saml\_provider\_arn](#output\_saml\_provider\_arn) | ARN of the SAML identity provider |
| <a name="output_saml_provider_name"></a> [saml\_provider\_name](#output\_saml\_provider\_name) | Name of the SAML identity provider |
<!-- END_TF_DOCS -->
