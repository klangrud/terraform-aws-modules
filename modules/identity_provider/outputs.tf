output "saml_provider_arn" {
  description = "ARN of the SAML identity provider"
  value       = aws_iam_saml_provider.this.arn
}

output "saml_provider_name" {
  description = "Name of the SAML identity provider"
  value       = aws_iam_saml_provider.this.name
}

output "role_discovery_user_name" {
  description = "Name of the IAM user for role discovery (if created)"
  value       = var.create_role_discovery_user ? aws_iam_user.role_discovery[0].name : null
}

output "role_discovery_user_arn" {
  description = "ARN of the IAM user for role discovery (if created)"
  value       = var.create_role_discovery_user ? aws_iam_user.role_discovery[0].arn : null
}
