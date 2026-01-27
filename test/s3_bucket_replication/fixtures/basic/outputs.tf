output "source_bucket_name" {
  description = "Name of the source bucket"
  value       = module.s3_replication.source_bucket_name
}

output "source_bucket_arn" {
  description = "ARN of the source bucket"
  value       = module.s3_replication.source_bucket_arn
}

output "destination_bucket_name" {
  description = "Name of the destination bucket"
  value       = module.s3_replication.destination_bucket_name
}

output "destination_bucket_arn" {
  description = "ARN of the destination bucket"
  value       = module.s3_replication.destination_bucket_arn
}

output "source_replication_role_arn" {
  description = "ARN of the source replication role"
  value       = module.s3_replication.source_replication_role_arn
}

output "destination_replication_role_arn" {
  description = "ARN of the destination replication role (null if not bidirectional)"
  value       = module.s3_replication.destination_replication_role_arn
}

output "is_bidirectional" {
  description = "Whether bidirectional replication is enabled"
  value       = module.s3_replication.is_bidirectional
}

output "is_cross_account" {
  description = "Whether this is cross-account replication"
  value       = module.s3_replication.is_cross_account
}
