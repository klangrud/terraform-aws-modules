data "aws_iam_policy_document" "enforce_secure_transport" {
  statement {
    sid = "Enforce-Secure-Transport"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "s3:*"
    ]

    resources = [
      "${aws_s3_bucket.s3_bucket.arn}/*",
      aws_s3_bucket.s3_bucket.arn
    ]

    effect = "Deny"

    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }

    condition {
      test     = "NumericLessThan"
      values   = [1.2]
      variable = "s3:TlsVersion"
    }
  }
}
