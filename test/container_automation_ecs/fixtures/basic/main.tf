provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
}

module "container_automation_ecs" {
  source = "../../../../modules/container_automation_ecs"

  aws_ecr_image_repository_name = var.aws_ecr_image_repository_name
  family                        = var.family
  container_definitions         = var.container_definitions
  task_role_arn                 = var.task_role_arn
  execution_role_arn            = var.execution_role_arn
  network_mode                  = var.network_mode
  fargate                       = var.fargate
  cpu                           = var.cpu
  memory                        = var.memory
  operating_system_family       = var.operating_system_family
  cpu_architecture              = var.cpu_architecture
}
