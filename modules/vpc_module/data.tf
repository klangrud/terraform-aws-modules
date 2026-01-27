# data.tf
# Only fetch AZs from AWS when mock_azs is not provided
# This allows unit tests to run without AWS credentials
data "aws_availability_zones" "available" {
  count = var.mock_azs == null ? 1 : 0
  state = "available"
}
