output "saml_provider_arn" {
  description = "ARN of the SAML provider"
  value       = module.identity_provider.saml_provider_arn
}

output "saml_provider_name" {
  description = "Name of the SAML provider"
  value       = module.identity_provider.saml_provider_name
}

output "role_discovery_user_name" {
  description = "Name of the role discovery user"
  value       = module.identity_provider.role_discovery_user_name
}

output "role_discovery_user_arn" {
  description = "ARN of the role discovery user"
  value       = module.identity_provider.role_discovery_user_arn
}
