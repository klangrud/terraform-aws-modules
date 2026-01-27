variable "aws_ecr_image_repository_name" {
  description = "Name of the ECR repository"
  type        = string
  default     = "test-app"
}

variable "family" {
  description = "Task definition family name"
  type        = string
  default     = "test-task"
}

variable "container_definitions" {
  description = "Container definitions"
  type        = list(any)
  default = [
    {
      name      = "test-container"
      image     = "nginx:latest"
      cpu       = 128
      memory    = 256
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
    }
  ]
}

variable "task_role_arn" {
  description = "Task role ARN"
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "Execution role ARN"
  type        = string
  default     = null
}

variable "network_mode" {
  description = "Network mode"
  type        = string
  default     = null
}

variable "fargate" {
  description = "Use Fargate"
  type        = bool
  default     = false
}

variable "cpu" {
  description = "CPU units"
  type        = number
  default     = 128
}

variable "memory" {
  description = "Memory in MiB"
  type        = number
  default     = 512
}

variable "operating_system_family" {
  description = "OS family"
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "CPU architecture"
  type        = string
  default     = "X86_64"
}
