variable "aws_ecr_image_repository_name" {
  description = "(Required) Name of the ECR Repository"
  type        = string
}

variable "family" {
  description = "(Required) A unique name for your task definition."
  type        = string
}

variable "container_definitions" {
  description = "(Required) A list of valid container definitions."
  type        = list(any)
}

variable "task_role_arn" {
  description = "(Optional) ARN of IAM role that allows your Amazon ECS container task to make calls to other AWS services."
  type        = string
  default     = null
}

variable "execution_role_arn" {
  description = "(Optional) ARN of the task execution role that the Amazon ECS container agent and the Docker daemon can assume."
  type        = string
  default     = null
}

variable "network_mode" {
  description = "(Optional) Docker networking mode to use for the containers in the task. Valid values are none, bridge, awsvpc, and host."
  type        = string
  default     = null
}

variable "fargate" {
  description = "(Optional) If this is true, it will set the requires_compatibilities to FARGATE."
  type        = bool
  default     = false
}

variable "cpu" {
  description = "(Optional) Number of cpu units used by the task. If the fargate is true this field is required. CPU units available, the task fails. Supported values are between 128 CPU units (0.125 vCPUs) and 10240 CPU units (10 vCPUs)."
  type        = number
  default     = 128
}

variable "memory" {
  description = "(Optional) Amount (in MiB) of memory used by the task. If fargate is true this field is required."
  type        = number
  default     = 512
}

variable "operating_system_family" {
  description = "Optional) If the fargate is true this field is required; must be set to a valid option from the operating system family in the runtime platform setting"
  type        = string
  default     = "LINUX"
}

variable "cpu_architecture" {
  description = "(Optional) Must be set to either X86_64 or ARM64"
  type        = string
  default     = "X86_64"
}
