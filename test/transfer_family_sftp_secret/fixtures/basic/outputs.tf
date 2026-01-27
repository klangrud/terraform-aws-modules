output "secret_arn" {
  description = "ARN of the Secrets Manager secret"
  value       = module.transfer_family_sftp_secret.secret_arn
}

output "secret_id" {
  description = "ID of the Secrets Manager secret"
  value       = module.transfer_family_sftp_secret.secret_id
}

output "secret_name" {
  description = "Name of the Secrets Manager secret"
  value       = module.transfer_family_sftp_secret.secret_name
}
