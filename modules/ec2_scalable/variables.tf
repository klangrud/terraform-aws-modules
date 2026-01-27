############################################
# General Configuration
############################################

variable "tags" {
  description = "AWS Tags that can be applied to a resource that accepts them."
  type        = map(string)
  default     = {}
}

variable "project_name" {
  description = "Name of the project or application (e.g., research-hub)."
  type        = string
}

variable "env_short" {
  description = "Short form of the environment (e.g., dev, test, prod)."
  type        = string
}

############################################
# EC2 Instance Configuration
############################################

variable "ami_id" {
  description = "Amazon Machine Image (AMI) ID for the EC2 instance. Defaults to secure Amazon Linux 2023 AMI."
  type        = string
  default     = "ami-0017468bf94789869"
}

variable "instance_type" {
  description = "EC2 Instance Type. Defaults to t3a.medium for cost-effective performance."
  type        = string
  default     = "t3a.medium"
}

variable "instance_count" {
  description = "Number of EC2 instances to create. Set to 1 for single instance, or higher for scalability."
  type        = number
  default     = 1

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 100
    error_message = "Instance count must be between 1 and 100."
  }
}

variable "ec2_key_pair" {
  description = "EC2 Key Pair Name (must exist in the region)."
  type        = string
}

variable "enable_detailed_monitoring" {
  description = "Enable detailed CloudWatch monitoring for the EC2 instance (incurs additional costs)."
  type        = bool
  default     = false
}

variable "disable_api_termination" {
  description = "If true, enables EC2 Instance Termination Protection."
  type        = bool
  default     = true
}

############################################
# Storage Configuration - Root Block Device
############################################

variable "root_block_device" {
  description = "Configuration for the root block device (primary storage)."
  type = object({
    encrypted   = bool
    volume_type = string
    volume_size = number
    iops        = optional(number)
    throughput  = optional(number)
  })
  default = {
    encrypted   = true
    volume_type = "gp3"
    volume_size = 30
    iops        = 3000
    throughput  = 125
  }
}

############################################
# Storage Configuration - Additional EBS Volumes
############################################

variable "enable_data_volume" {
  description = "Enable a default /data volume mounted at /data."
  type        = bool
  default     = false
}

variable "data_volume_size" {
  description = "Size in GB for the default /data volume (only used if enable_data_volume is true)."
  type        = number
  default     = 100
}

variable "additional_ebs_volumes" {
  description = "List of additional EBS volumes to create and mount. Each volume requires device_name, mount_point, volume_size, and optionally volume_type, iops, throughput, and encrypted."
  type = list(object({
    device_name = string
    mount_point = string
    volume_size = number
    volume_type = optional(string, "gp3")
    iops        = optional(number, 3000)
    throughput  = optional(number, 125)
    encrypted   = optional(bool, true)
    filesystem  = optional(string, "ext4")
  }))
  default = []

  validation {
    condition = alltrue([
      for vol in var.additional_ebs_volumes :
      can(regex("^/dev/(sd[f-p]|xvd[f-p])$", vol.device_name))
    ])
    error_message = "Device names must be in the format /dev/sdf through /dev/sdp (or xvdf through xvdp)."
  }

  validation {
    condition = alltrue([
      for vol in var.additional_ebs_volumes :
      can(regex("^/[a-zA-Z0-9/_-]+$", vol.mount_point))
    ])
    error_message = "Mount points must be absolute paths starting with /."
  }
}

############################################
# Network Configuration
############################################

variable "vpc_id" {
  description = "VPC ID where the EC2 instance will reside."
  type        = string
}

variable "subnet_count" {
  description = "Optional explicit number of subnets. If set, avoids count depending on unknown subnet_ids length."
  type        = number
  default     = null
}

variable "subnet_ids" {
  description = "List of subnet IDs for EC2 placement. If instance_count > 1, instances will be distributed across subnets."
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided."
  }
}

variable "associate_public_ip_address" {
  description = "Associate a public IP address with the EC2 instance."
  type        = bool
  default     = false
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to the EC2 instances. If empty, a default security group will be created."
  type        = list(string)
  default     = []
}

variable "create_security_group" {
  description = "If true, creates a default security group for the EC2 instances."
  type        = bool
  default     = true
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to access the EC2 instances (used if create_security_group is true)."
  type        = list(string)
  default     = []
}

variable "allowed_ssh_cidr_blocks" {
  description = "CIDR blocks allowed SSH access (port 22) to the EC2 instances."
  type        = list(string)
  default     = []
}

############################################
# IAM Configuration
############################################

variable "iam_instance_profile" {
  description = "IAM Instance Profile Name for the EC2 instance. If not provided, a default profile with SSM permissions will be created."
  type        = string
  default     = null
}

variable "create_iam_instance_profile" {
  description = "If true, creates an IAM instance profile with SSM permissions."
  type        = bool
  default     = true
}

variable "additional_iam_policies" {
  description = "List of additional IAM policy ARNs to attach to the instance profile."
  type        = list(string)
  default     = []
}

############################################
# User Data Configuration
############################################

variable "enable_security_updates" {
  description = "Apply security updates on first boot."
  type        = bool
  default     = true
}

variable "custom_user_data_parts" {
  description = "List of custom cloud-init user data parts to include. Each part should have content_type, filename, and content."
  type = list(object({
    content_type = string
    filename     = string
    content      = string
  }))
  default = []
}

variable "install_ssm_agent" {
  description = "Install AWS SSM Agent on first boot."
  type        = bool
  default     = true
}

############################################
# Optional Configuration
############################################

variable "environment" {
  description = "Full environment name (legacy compatibility)."
  type        = string
  default     = ""
}

variable "name_prefix" {
  description = "Prefix for resource names. If not provided, defaults to project_name-env_short."
  type        = string
  default     = ""
}
