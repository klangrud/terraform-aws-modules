# AWS Managed Key for SNS
data "aws_kms_key" "sns" {
  key_id = "alias/aws/sns"
}
