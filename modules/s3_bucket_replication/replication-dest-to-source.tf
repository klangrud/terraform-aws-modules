# ================================================================================
# DESTINATION → SOURCE REPLICATION (Bidirectional Only)
# ================================================================================

resource "aws_s3_bucket_replication_configuration" "destination_to_source" {
  count    = var.enable_bidirectional ? 1 : 0
  provider = aws.destination
  bucket   = local.destination_bucket_name
  role     = local.destination_replication_role_arn

  # Ensure versioning and IAM roles are enabled first
  depends_on = [
    module.source_bucket,
    module.destination_bucket,
    aws_s3_bucket_versioning.source_existing_versioning,
    aws_s3_bucket_versioning.destination_existing_versioning,
    aws_iam_role.destination_replication,
    aws_iam_role_policy_attachment.destination_replication,
    aws_s3_bucket_policy.source_existing_policy
  ]

  # Create one rule per reverse replication rule configuration
  # Priorities are auto-assigned starting after forward replication rules
  # Example: if forward has 3 rules (1,2,3), reverse gets (4,5,6)
  dynamic "rule" {
    for_each = { for idx, rule_config in var.reverse_replication_rules : idx => rule_config }

    content {
      id       = rule.value.prefix != "" ? "destination-to-source-${replace(rule.value.prefix, "/", "-")}" : "destination-to-source-all"
      priority = rule.key + 1 + length(var.replication_rules)
      status   = "Enabled"

      filter {
        prefix = rule.value.prefix
      }

      destination {
        bucket        = local.source_bucket_arn
        storage_class = rule.value.storage_class # null means use source object's storage class (AWS default)

        # Cross-account ownership override
        dynamic "access_control_translation" {
          for_each = local.is_cross_account ? [1] : []
          content {
            owner = "Destination"
          }
        }

        # Only specify account for cross-account replication
        account = local.is_cross_account ? var.source_account_id : null

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
