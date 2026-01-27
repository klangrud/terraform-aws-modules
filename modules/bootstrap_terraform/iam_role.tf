# This terraform file manages the terraform service role and its policies.

## AWS IAM Role for terraform
resource "aws_iam_role" "terraform-service-role" {
  name = "terraform-service-role-${var.short_env}"
  assume_role_policy = templatefile(
    "${path.module}/templates/trust_policy.json.tpl",
    { aws_account_id = var.aws_account_id, infra_account_id = var.infra_account_id }
  )
  max_session_duration = var.max_session_timeout_terraform_service_role
}

resource "aws_iam_role_policy_attachment" "terraform-service-role" {
  count      = length(var.aws_policy_arns_terraform_service_role)
  role       = aws_iam_role.terraform-service-role.name
  policy_arn = var.aws_policy_arns_terraform_service_role[count.index]
}
