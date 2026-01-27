resource "aws_ecs_task_definition" "task" {
  family                = var.family
  container_definitions = jsonencode(var.container_definitions)

  task_role_arn      = var.task_role_arn
  execution_role_arn = var.execution_role_arn

  network_mode = var.network_mode

  requires_compatibilities = var.fargate ? ["FARGATE"] : null

  cpu    = var.cpu
  memory = var.memory

  runtime_platform {
    operating_system_family = var.operating_system_family
    cpu_architecture        = var.cpu_architecture
  }
}
