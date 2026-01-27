data "aws_caller_identity" "current" {
  provider = aws.provider
}
data "aws_region" "current" {
  provider = aws.provider
}
