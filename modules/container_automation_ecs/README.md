# Container Automation ECS Module

A Terraform module for creating ECS task definitions with container registry integration.

## Features

- ECS task definition creation
- ECR image integration
- Support for both Fargate and EC2 launch types
- Customizable CPU and memory allocation
- IAM role integration for task and execution roles
- Runtime platform configuration (OS and CPU architecture)

## Usage

### Basic Fargate Task Definition

```hcl
module "fargate_task" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/container_automation_ecs?ref=main"

  family                        = "my-application-task"
  aws_ecr_image_repository_name = "my-app"
  fargate                       = true
  cpu                           = 256
  memory                        = 512
  network_mode                  = "awsvpc"

  container_definitions = [
    {
      name      = "app-container"
      image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-app:latest"
      essential = true
      environment = [
        {
          name  = "ENV"
          value = "production"
        }
      ]
    }
  ]

  task_role_arn      = "arn:aws:iam::123456789012:role/MyTaskRole"
  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
}
```

### EC2 Launch Type Task

```hcl
module "ec2_task" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/container_automation_ecs?ref=main"

  family                        = "my-ec2-task"
  aws_ecr_image_repository_name = "my-service"
  fargate                       = false
  network_mode                  = "bridge"

  container_definitions = [
    {
      name      = "service-container"
      image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-service:v1.0.0"
      cpu       = 512
      memory    = 1024
      essential = true
    }
  ]

  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
}
```

### ARM64 Architecture Task

```hcl
module "arm_task" {
  source = "git::https://github.com/klangrud/terraform-aws-modules.git//modules/container_automation_ecs?ref=main"

  family                        = "arm-optimized-task"
  aws_ecr_image_repository_name = "my-arm-app"
  fargate                       = true
  cpu                           = 1024
  memory                        = 2048
  network_mode                  = "awsvpc"
  cpu_architecture              = "ARM64"

  container_definitions = [
    {
      name      = "app"
      image     = "123456789012.dkr.ecr.us-east-1.amazonaws.com/my-arm-app:latest"
      essential = true
    }
  ]

  execution_role_arn = "arn:aws:iam::123456789012:role/ecsTaskExecutionRole"
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_ecs_task_definition.task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_ecr_image.image](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ecr_image) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_ecr_image_repository_name"></a> [aws\_ecr\_image\_repository\_name](#input\_aws\_ecr\_image\_repository\_name) | (Required) Name of the ECR Repository | `string` | n/a | yes |
| <a name="input_container_definitions"></a> [container\_definitions](#input\_container\_definitions) | (Required) A list of valid container definitions. | `list(any)` | n/a | yes |
| <a name="input_cpu"></a> [cpu](#input\_cpu) | (Optional) Number of cpu units used by the task. If the fargate is true this field is required. CPU units available, the task fails. Supported values are between 128 CPU units (0.125 vCPUs) and 10240 CPU units (10 vCPUs). | `number` | `128` | no |
| <a name="input_cpu_architecture"></a> [cpu\_architecture](#input\_cpu\_architecture) | (Optional) Must be set to either X86\_64 or ARM64 | `string` | `"X86_64"` | no |
| <a name="input_execution_role_arn"></a> [execution\_role\_arn](#input\_execution\_role\_arn) | (Optional) ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume. | `string` | `null` | no |
| <a name="input_family"></a> [family](#input\_family) | (Required) A unique name for your task definition. | `string` | n/a | yes |
| <a name="input_fargate"></a> [fargate](#input\_fargate) | (Optional) If this is true, it will set the requires\_compatibilities to FARGATE. | `bool` | `false` | no |
| <a name="input_memory"></a> [memory](#input\_memory) | (Optional) Amount (in MiB) of memory used by the task. If fargate is true this field is required. | `number` | `512` | no |
| <a name="input_network_mode"></a> [network\_mode](#input\_network\_mode) | (Optional) Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host. | `string` | `null` | no |
| <a name="input_operating_system_family"></a> [operating\_system\_family](#input\_operating\_system\_family) | Optional) If the fargate is true this field is required; must be set to a valid option from the operating system family in the runtime platform setting | `string` | `"LINUX"` | no |
| <a name="input_task_role_arn"></a> [task\_role\_arn](#input\_task\_role\_arn) | (Optional) ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_image_tag"></a> [image\_tag](#output\_image\_tag) | n/a |
| <a name="output_repo_name"></a> [repo\_name](#output\_repo\_name) | n/a |
<!-- END_TF_DOCS -->
