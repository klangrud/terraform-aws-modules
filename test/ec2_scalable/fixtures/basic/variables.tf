############################################
# General Configuration
############################################

variable "project_name" {
  type    = string
  default = "test-ec2"
}

variable "env_short" {
  type    = string
  default = "test"
}

variable "tags" {
  type    = map(string)
  default = {}
}

############################################
# EC2 Instance Configuration
############################################

variable "ami_id" {
  type    = string
  default = "ami-0017468bf94789869"
}

variable "instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "instance_count" {
  type    = number
  default = 1
}

variable "ec2_key_pair" {
  type = string
}

variable "enable_detailed_monitoring" {
  type    = bool
  default = false
}

variable "disable_api_termination" {
  type    = bool
  default = false
}

############################################
# Storage Configuration
############################################

variable "root_block_device" {
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

variable "enable_data_volume" {
  type    = bool
  default = false
}

variable "data_volume_size" {
  type    = number
  default = 100
}

variable "additional_ebs_volumes" {
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
}

############################################
# Network Configuration
############################################

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "subnet_count" {
  type    = number
  default = null
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "create_security_group" {
  type    = bool
  default = true
}

variable "allowed_cidr_blocks" {
  type    = list(string)
  default = []
}

variable "allowed_ssh_cidr_blocks" {
  type    = list(string)
  default = []
}

############################################
# IAM Configuration
############################################

variable "iam_instance_profile" {
  type    = string
  default = null
}

variable "create_iam_instance_profile" {
  type    = bool
  default = true
}

variable "additional_iam_policies" {
  type    = list(string)
  default = []
}

############################################
# User Data Configuration
############################################

variable "enable_security_updates" {
  type    = bool
  default = true
}

variable "install_ssm_agent" {
  type    = bool
  default = true
}

variable "custom_user_data_parts" {
  type = list(object({
    content_type = string
    filename     = string
    content      = string
  }))
  default = []
}

############################################
# Optional Configuration
############################################

variable "environment" {
  type    = string
  default = ""
}

variable "name_prefix" {
  type    = string
  default = ""
}
