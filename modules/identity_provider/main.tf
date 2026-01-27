# ---------------------------------------------------------------------------------------------------------------------
# SAML Identity Provider
# Works with any SAML 2.0 compatible IdP (Okta, Azure AD, Google Workspace, OneLogin, etc.)
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_saml_provider" "this" {
  name                   = "${var.provider_name}-${var.env}"
  saml_metadata_document = var.saml_metadata_document

  tags = var.tags
}

# ---------------------------------------------------------------------------------------------------------------------
# Role Discovery User (Optional)
# Some IdPs (like Okta) require an IAM user to dynamically discover available roles
# ---------------------------------------------------------------------------------------------------------------------

resource "aws_iam_user" "role_discovery" {
  count = var.create_role_discovery_user ? 1 : 0

  name = "${var.role_discovery_user_name}-${var.env}"
  tags = var.tags
}

resource "aws_iam_policy" "role_discovery" {
  count = var.create_role_discovery_user ? 1 : 0

  name        = "SAMLRoleDiscoveryPolicy-${var.env}"
  description = "Allows IdP to list available IAM roles for SSO"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "iam:ListRoles",
          "iam:ListAccountAliases"
        ]
        Resource = "*"
      }
    ]
  })

  tags = var.tags
}

resource "aws_iam_user_policy_attachment" "role_discovery" {
  count = var.create_role_discovery_user ? 1 : 0

  user       = aws_iam_user.role_discovery[0].name
  policy_arn = aws_iam_policy.role_discovery[0].arn
}
