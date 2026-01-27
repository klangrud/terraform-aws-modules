variable "source_bucket_name" {
  type        = string
  description = "Name of the source S3 bucket"
}

variable "destination_bucket_name" {
  type        = string
  description = "Name of the destination S3 bucket"
}

variable "source_account_id" {
  type        = string
  description = "Source AWS account ID"
}

variable "destination_account_id" {
  type        = string
  description = "Destination AWS account ID"
}

variable "source_bucket_exists" {
  type        = bool
  default     = false
  description = "Whether source bucket already exists"
}

variable "destination_bucket_exists" {
  type        = bool
  default     = false
  description = "Whether destination bucket already exists"
}

variable "enable_bidirectional" {
  type        = bool
  default     = false
  description = "Enable bidirectional replication"
}

variable "replication_rules" {
  type = list(object({
    prefix                    = string
    delete_marker_replication = optional(bool, true)
    storage_class             = optional(string, "STANDARD")
    replica_kms_key_id        = optional(string, null)
  }))
  default = [
    {
      prefix = ""
    }
  ]
  description = "Replication rules"
}

variable "reverse_replication_rules" {
  type = list(object({
    prefix                    = string
    delete_marker_replication = optional(bool, true)
    storage_class             = optional(string, "STANDARD")
    replica_kms_key_id        = optional(string, null)
  }))
  default = [
    {
      prefix = ""
    }
  ]
  description = "Reverse replication rules"
}

variable "source_replication_role_arn" {
  type        = string
  default     = null
  description = "Existing source replication role ARN"
}

variable "destination_replication_role_arn" {
  type        = string
  default     = null
  description = "Existing destination replication role ARN"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to resources"
}
