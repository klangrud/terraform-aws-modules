module "bootstrap" {
  source = "../../../../modules/bootstrap_terraform"

  s3_bucket_name      = var.s3_bucket_name
  dynamodb_table_name = var.dynamodb_table_name
  short_env           = var.short_env
  aws_account_id      = var.aws_account_id
  infra_account_id    = var.infra_account_id
  tags                = var.tags

  aws_policy_arns_terraform_service_role     = var.aws_policy_arns_terraform_service_role
  max_session_timeout_terraform_service_role = var.max_session_timeout_terraform_service_role
}
