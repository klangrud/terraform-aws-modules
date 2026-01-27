locals {
  # ================================================================================
  # BUCKET ARNS AND NAMES
  # ================================================================================

  # Source bucket ARN: use existing or constructed from new bucket
  source_bucket_arn = var.source_bucket_exists ? (
    data.aws_s3_bucket.source_existing[0].arn
    ) : (
    module.source_bucket[0].aws_s3_bucket_arn
  )

  # Source bucket name: use existing or from new bucket
  source_bucket_name = var.source_bucket_exists ? (
    data.aws_s3_bucket.source_existing[0].id
    ) : (
    module.source_bucket[0].aws_s3_bucket_name
  )

  # Destination bucket ARN: use existing or constructed from new bucket
  destination_bucket_arn = var.destination_bucket_exists ? (
    data.aws_s3_bucket.destination_existing[0].arn
    ) : (
    module.destination_bucket[0].aws_s3_bucket_arn
  )

  # Destination bucket name: use existing or from new bucket
  destination_bucket_name = var.destination_bucket_exists ? (
    data.aws_s3_bucket.destination_existing[0].id
    ) : (
    module.destination_bucket[0].aws_s3_bucket_name
  )

  # ================================================================================
  # IAM ROLE CONFIGURATION
  # ================================================================================

  # Determine if we need to create roles
  create_source_role      = var.source_replication_role_arn == null
  create_destination_role = var.enable_bidirectional && var.destination_replication_role_arn == null

  # Role names with defaults
  source_role_name = var.source_replication_role_name != null ? (
    var.source_replication_role_name
    ) : (
    "replication-role-${var.source_bucket_name}"
  )

  destination_role_name = var.destination_replication_role_name != null ? (
    var.destination_replication_role_name
    ) : (
    "replication-role-${var.destination_bucket_name}"
  )

  # IAM Role ARNs: use provided or create new
  source_replication_role_arn = var.source_replication_role_arn != null ? (
    var.source_replication_role_arn
    ) : (
    aws_iam_role.source_replication[0].arn
  )

  destination_replication_role_arn = var.enable_bidirectional ? (
    var.destination_replication_role_arn != null ? (
      var.destination_replication_role_arn
      ) : (
      aws_iam_role.destination_replication[0].arn
    )
  ) : null

  # ================================================================================
  # CROSS-ACCOUNT DETECTION
  # ================================================================================

  # Cross-account flag
  is_cross_account = var.source_account_id != var.destination_account_id
}
