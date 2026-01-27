resource "aws_s3_bucket_policy" "s3_bucket" {
  provider = aws.provider
  bucket   = aws_s3_bucket.s3_bucket.id

  policy = data.aws_iam_policy_document.bucket_merged.json
}

data "aws_iam_policy_document" "bucket_merged" {
  # Start with your base “secure transport” policy
  source_policy_documents = concat(
    [
      data.aws_iam_policy_document.enforce_secure_transport.json,
    ],
    # Plus everything the caller passed in
    var.bucket_policies_json
  )

  # Optional: if you ever want to override Sids from above:
  # override_policy_documents = [
  #   data.aws_iam_policy_document.some_override.json,
  # ]
}
