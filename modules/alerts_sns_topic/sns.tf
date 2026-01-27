resource "aws_sns_topic" "sns_topic" {
  name              = var.sns_topic_name
  kms_master_key_id = data.aws_kms_key.sns.arn
}

resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn    = aws_sns_topic.sns_topic.arn
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_sns_topic_subscription" "sns_topic_subscription" {
  endpoint  = var.email_recipient
  protocol  = "email"
  topic_arn = aws_sns_topic.sns_topic.arn
}
