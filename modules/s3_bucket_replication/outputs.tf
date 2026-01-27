output "source_bucket_name" {
  description = "Name of the source bucket"
  value       = local.source_bucket_name
}

output "source_bucket_arn" {
  description = "ARN of the source bucket"
  value       = local.source_bucket_arn
}

output "destination_bucket_name" {
  description = "Name of the destination bucket"
  value       = local.destination_bucket_name
}

output "destination_bucket_arn" {
  description = "ARN of the destination bucket"
  value       = local.destination_bucket_arn
}

output "source_replication_role_arn" {
  description = "ARN of the IAM role used for source → destination replication"
  value       = local.source_replication_role_arn
}

output "destination_replication_role_arn" {
  description = "ARN of the IAM role used for destination → source replication (null if not bidirectional)"
  value       = local.destination_replication_role_arn
}

output "is_bidirectional" {
  description = "Whether bidirectional replication is enabled"
  value       = var.enable_bidirectional
}

output "is_cross_account" {
  description = "Whether this is cross-account replication"
  value       = local.is_cross_account
}

output "replication_configuration_id" {
  description = "ID of the source → destination replication configuration"
  value       = aws_s3_bucket_replication_configuration.source_to_destination.id
}
