# ================================================================================
# SOURCE REPLICATION ROLE (Source → Destination)
# ================================================================================

resource "aws_iam_role" "source_replication" {
  count    = local.create_source_role ? 1 : 0
  provider = aws.source

  name = local.source_role_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "source_replication" {
  count    = local.create_source_role ? 1 : 0
  provider = aws.source

  name = "${local.source_role_name}-policy"
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Read permissions on source bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ]
        Resource = ["${local.source_bucket_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration"
        ]
        Resource = [local.source_bucket_arn]
      },
      # Write permissions on destination bucket
      {
        Effect = "Allow"
        Action = concat(
          [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
          ],
          local.is_cross_account ? ["s3:ObjectOwnerOverrideToBucketOwner"] : []
        )
        Resource = ["${local.destination_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "source_replication" {
  count      = local.create_source_role ? 1 : 0
  provider   = aws.source
  role       = aws_iam_role.source_replication[0].name
  policy_arn = aws_iam_policy.source_replication[0].arn
}

# ================================================================================
# DESTINATION REPLICATION ROLE (Destination → Source, bidirectional only)
# ================================================================================

resource "aws_iam_role" "destination_replication" {
  count    = local.create_destination_role ? 1 : 0
  provider = aws.destination

  name = local.destination_role_name
  tags = var.tags

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "s3.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "destination_replication" {
  count    = local.create_destination_role ? 1 : 0
  provider = aws.destination

  name = "${local.destination_role_name}-policy"
  tags = var.tags

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Read permissions on destination bucket
      {
        Effect = "Allow"
        Action = [
          "s3:GetObjectVersionForReplication",
          "s3:GetObjectVersionAcl",
          "s3:GetObjectVersionTagging",
          "s3:GetObjectRetention",
          "s3:GetObjectLegalHold"
        ]
        Resource = ["${local.destination_bucket_arn}/*"]
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetReplicationConfiguration"
        ]
        Resource = [local.destination_bucket_arn]
      },
      # Write permissions on source bucket
      {
        Effect = "Allow"
        Action = concat(
          [
            "s3:ReplicateObject",
            "s3:ReplicateDelete",
            "s3:ReplicateTags"
          ],
          local.is_cross_account ? ["s3:ObjectOwnerOverrideToBucketOwner"] : []
        )
        Resource = ["${local.source_bucket_arn}/*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "destination_replication" {
  count      = local.create_destination_role ? 1 : 0
  provider   = aws.destination
  role       = aws_iam_role.destination_replication[0].name
  policy_arn = aws_iam_policy.destination_replication[0].arn
}
