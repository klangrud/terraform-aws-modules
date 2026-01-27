# ================================================================================
# SOURCE → DESTINATION REPLICATION
# ================================================================================

resource "aws_s3_bucket_replication_configuration" "source_to_destination" {
  provider = aws.source
  bucket   = local.source_bucket_name
  role     = local.source_replication_role_arn

  # Ensure versioning and IAM roles are enabled first
  depends_on = [
    module.source_bucket,
    module.destination_bucket,
    aws_s3_bucket_versioning.source_existing_versioning,
    aws_s3_bucket_versioning.destination_existing_versioning,
    aws_iam_role.source_replication,
    aws_iam_role_policy_attachment.source_replication,
    aws_s3_bucket_policy.destination_existing_policy
  ]

  # Create one rule per replication rule configuration
  # Priorities are auto-assigned: 1, 2, 3, etc.
  dynamic "rule" {
    for_each = { for idx, rule_config in var.replication_rules : idx => rule_config }

    content {
      id       = rule.value.prefix != "" ? "source-to-destination-${replace(rule.value.prefix, "/", "-")}" : "source-to-destination-all"
      priority = rule.key + 1
      status   = "Enabled"

      filter {
        prefix = rule.value.prefix
      }

      destination {
        bucket        = local.destination_bucket_arn
        storage_class = rule.value.storage_class # null means use source object's storage class (AWS default)

        # Cross-account ownership override
        dynamic "access_control_translation" {
          for_each = local.is_cross_account ? [1] : []
          content {
            owner = "Destination"
          }
        }

        # Only specify account for cross-account replication
        account = local.is_cross_account ? var.destination_account_id : null

        # KMS encryption for replicas (optional)
        dynamic "encryption_configuration" {
          for_each = rule.value.replica_kms_key_id != null ? [1] : []
          content {
            replica_kms_key_id = rule.value.replica_kms_key_id
          }
        }
      }

      delete_marker_replication {
        status = rule.value.delete_marker_replication ? "Enabled" : "Disabled"
      }
    }
  }
}
