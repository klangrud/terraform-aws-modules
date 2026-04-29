variable "name" {
  description = "The name of the VPC"
  type        = string
}

variable "region" {
  description = "The AWS region where the VPC will be created"
  type        = string
}
variable "vpc_cidr" {
  type        = string
  description = "The CIDR block for the VPC. Supported sizes: /16 to /24."

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }

  validation {
    condition     = tonumber(split("/", var.vpc_cidr)[1]) >= 16 && tonumber(split("/", var.vpc_cidr)[1]) <= 24
    error_message = "vpc_cidr prefix must be between /16 and /24. Smaller than /24 cannot support minimum AWS subnet size (/28)."
  }
}

variable "additional_custom_subnets" {
  description = "Map of additional custom subnets to create"
  type = map(object({
    type       = string
    cidr_block = string
  }))
}

variable "create_rds_subnets" {
  type        = bool
  description = "Whether to create RDS subnets"
  default     = false
}

variable "create_internet_gateway" {
  description = "Whether to create an Internet Gateway for the VPC"
  type        = bool
  default     = true
}

variable "create_nat_gateway" {
  description = "Whether to create a NAT Gateway for the VPC"
  type        = bool
  default     = true
}

variable "nat_gateway_per_az" {
  description = "When true, creates one NAT Gateway per AZ where private subnets exist (high availability). When false (default), creates a single NAT Gateway in the first AZ (cost-optimized, single point of failure)."
  type        = bool
  default     = false
}

variable "create_vpc_flow_logs" {
  type        = bool
  default     = false
  description = "Whether to create VPC flow logs and related resources"
}

variable "vpc_endpoints" {
  description = "List of AWS services to create VPC endpoints for"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "test_resource_tag" {
  description = "Optional tag to mark resources created by automated tests for cleanup. Leave empty in normal usage."
  type        = string
  default     = ""
}

variable "public_subnet_count" {
  description = "How many public subnets (AZs) to allocate, default is 3. Max 6."
  type        = number
  default     = 3

  validation {
    condition     = var.public_subnet_count >= 1 && var.public_subnet_count <= 6
    error_message = "public_subnet_count must be between 1 and 6."
  }
}

variable "private_subnet_count" {
  description = "How many private subnets (AZs) to allocate, default is 3. Max 6."
  type        = number
  default     = 3

  validation {
    condition     = var.private_subnet_count >= 1 && var.private_subnet_count <= 6
    error_message = "private_subnet_count must be between 1 and 6."
  }
}

variable "rds_subnet_count" {
  description = "How many RDS subnets (AZs) to allocate, default is 3. Max 6."
  type        = number
  default     = 3

  validation {
    condition     = var.rds_subnet_count >= 1 && var.rds_subnet_count <= 6
    error_message = "rds_subnet_count must be between 1 and 6."
  }
}

variable "custom_subnets" {
  description = "List of custom subnets with name, public flag, and subnet_count (number of /24 subnets to allocate). Example: [ { name = \"app-subnet\", public = false, subnet_count = 3 } ]"
  type = list(object({
    name         = string
    public       = bool
    subnet_count = number
  }))
  default = []

  validation {
    condition     = alltrue([for c in var.custom_subnets : c.subnet_count >= 1 && c.subnet_count <= 6])
    error_message = "Each custom_subnet.subnet_count must be between 1 and 6."
  }
}

variable "mock_azs" {
  type        = list(string)
  default     = null
  description = "Mock AZs used for testing"
}
