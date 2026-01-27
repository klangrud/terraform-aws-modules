# ================================================================================
# BUCKET POLICY DOCUMENTS
# ================================================================================

# Destination bucket policy: Grants source replication role permissions
data "aws_iam_policy_document" "destination_bucket_policy" {
  statement {
    sid    = "AllowSourceReplication"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.source_replication_role_arn]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    resources = ["${local.destination_bucket_arn}/*"]
  }

  statement {
    sid    = "AllowSourceReplicationBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.source_replication_role_arn]
    }

    actions = [
      "s3:List*",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [local.destination_bucket_arn]
  }
}

# Source bucket policy: Grants destination replication role permissions (bidirectional only)
data "aws_iam_policy_document" "source_bucket_policy" {
  count = var.enable_bidirectional && local.create_destination_role ? 1 : 0

  statement {
    sid    = "AllowDestinationReplication"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.destination_replication_role_arn]
    }

    actions = [
      "s3:ReplicateObject",
      "s3:ReplicateDelete",
      "s3:ReplicateTags"
    ]

    resources = ["${local.source_bucket_arn}/*"]
  }

  statement {
    sid    = "AllowDestinationReplicationBucket"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [local.destination_replication_role_arn]
    }

    actions = [
      "s3:List*",
      "s3:GetBucketVersioning",
      "s3:PutBucketVersioning"
    ]

    resources = [local.source_bucket_arn]
  }
}

# ================================================================================
# SOURCE BUCKET CREATION
# ================================================================================

# Create source bucket only if it doesn't exist
module "source_bucket" {
  count  = var.source_bucket_exists ? 0 : 1
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=v1.0"

  bucket         = var.source_bucket_name
  versioning     = "Enabled" # Required for replication
  tags           = var.tags
  force_destroy  = var.force_destroy_buckets
  bucket_folders = var.source_bucket_folders
  enable_logging = var.enable_logging
  bucket_policies_json = concat(
    var.source_bucket_policies_json,
    var.enable_bidirectional && local.create_destination_role ? [data.aws_iam_policy_document.source_bucket_policy[0].json] : []
  )

  providers = {
    aws.provider = aws.source
  }
}

# ================================================================================
# DESTINATION BUCKET CREATION
# ================================================================================

# Create destination bucket only if it doesn't exist
module "destination_bucket" {
  count  = var.destination_bucket_exists ? 0 : 1
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/s3_bucket?ref=v1.0"

  bucket         = var.destination_bucket_name
  versioning     = "Enabled" # Required for replication
  tags           = var.tags
  force_destroy  = var.force_destroy_buckets
  bucket_folders = var.destination_bucket_folders
  enable_logging = var.enable_logging
  bucket_policies_json = concat(
    var.destination_bucket_policies_json,
    [data.aws_iam_policy_document.destination_bucket_policy.json]
  )

  providers = {
    aws.provider = aws.destination
  }
}

# ================================================================================
# VERSIONING FOR EXISTING BUCKETS
# ================================================================================

# Enable versioning on existing source bucket if needed
resource "aws_s3_bucket_versioning" "source_existing_versioning" {
  count    = var.source_bucket_exists ? 1 : 0
  provider = aws.source
  bucket   = data.aws_s3_bucket.source_existing[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable versioning on existing destination bucket if needed
resource "aws_s3_bucket_versioning" "destination_existing_versioning" {
  count    = var.destination_bucket_exists ? 1 : 0
  provider = aws.destination
  bucket   = data.aws_s3_bucket.destination_existing[0].id

  versioning_configuration {
    status = "Enabled"
  }
}

# ================================================================================
# BUCKET POLICIES FOR EXISTING BUCKETS
# ================================================================================

# Apply replication policy to existing destination bucket
resource "aws_s3_bucket_policy" "destination_existing_policy" {
  count    = var.destination_bucket_exists ? 1 : 0
  provider = aws.destination
  bucket   = data.aws_s3_bucket.destination_existing[0].id
  policy   = data.aws_iam_policy_document.destination_bucket_policy.json
}

# Apply replication policy to existing source bucket (bidirectional only)
resource "aws_s3_bucket_policy" "source_existing_policy" {
  count    = var.source_bucket_exists && var.enable_bidirectional ? 1 : 0
  provider = aws.source
  bucket   = data.aws_s3_bucket.source_existing[0].id
  policy   = data.aws_iam_policy_document.source_bucket_policy[0].json
}
