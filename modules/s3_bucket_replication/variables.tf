# ================================================================================
# BUCKET MANAGEMENT
# ================================================================================

variable "source_bucket_name" {
  type        = string
  description = "Name of the source S3 bucket for replication"
}

variable "source_bucket_exists" {
  type        = bool
  default     = false
  description = "Set to true if source bucket already exists and should not be created"
}

variable "destination_bucket_name" {
  type        = string
  description = "Name of the destination S3 bucket for replication"
}

variable "destination_bucket_exists" {
  type        = bool
  default     = false
  description = "Set to true if destination bucket already exists and should not be created"
}

# ================================================================================
# BUCKET CONFIGURATION (only used when creating buckets)
# ================================================================================

variable "source_bucket_folders" {
  type        = list(string)
  default     = []
  description = "List of folders to create in source bucket (only if creating new bucket)"
}

variable "destination_bucket_folders" {
  type        = list(string)
  default     = []
  description = "List of folders to create in destination bucket (only if creating new bucket)"
}

variable "source_bucket_policies_json" {
  type        = list(string)
  default     = []
  description = "Additional bucket policies for source bucket (only if creating new bucket)"
}

variable "destination_bucket_policies_json" {
  type        = list(string)
  default     = []
  description = "Additional bucket policies for destination bucket (only if creating new bucket)"
}

variable "force_destroy_buckets" {
  type        = bool
  default     = false
  description = "Allow destruction of buckets even if they contain objects"
}

variable "enable_logging" {
  type        = bool
  default     = false
  description = "Enable S3 access logging for created buckets. Requires logs-{region}-{account_id} bucket to exist in each provider account."
}

# ================================================================================
# REPLICATION CONFIGURATION
# ================================================================================

variable "enable_bidirectional" {
  type        = bool
  default     = false
  description = "Enable bidirectional replication (both source→dest and dest→source)"
}

variable "replication_rules" {
  type = list(object({
    prefix                    = string
    delete_marker_replication = optional(bool, false)
    storage_class             = optional(string, null)
    replica_kms_key_id        = optional(string, null)
  }))
  default = [
    {
      prefix = ""
    }
  ]
  description = <<-EOT
    List of replication rules for source→destination replication. Each rule creates a separate replication configuration.

    Fields:
    - prefix: Object key prefix for filtering (empty string means replicate all objects)
    - delete_marker_replication: Enable delete marker replication (default: false, matches AWS default)
    - storage_class: Storage class for replicated objects (default: null, uses source object's storage class). Valid values: STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE
    - replica_kms_key_id: KMS key ID for encrypting replicas (optional)
  EOT
}

variable "reverse_replication_rules" {
  type = list(object({
    prefix                    = string
    delete_marker_replication = optional(bool, false)
    storage_class             = optional(string, null)
    replica_kms_key_id        = optional(string, null)
  }))
  default = [
    {
      prefix = ""
    }
  ]
  description = <<-EOT
    List of replication rules for destination→source replication (only used if enable_bidirectional=true).

    Fields:
    - prefix: Object key prefix for filtering (empty string means replicate all objects)
    - delete_marker_replication: Enable delete marker replication (default: false, matches AWS default)
    - storage_class: Storage class for replicated objects (default: null, uses source object's storage class). Valid values: STANDARD, REDUCED_REDUNDANCY, STANDARD_IA, ONEZONE_IA, INTELLIGENT_TIERING, GLACIER, DEEP_ARCHIVE
    - replica_kms_key_id: KMS key ID for encrypting replicas (optional)
  EOT
}

# ================================================================================
# IAM ROLE MANAGEMENT
# ================================================================================

variable "source_replication_role_arn" {
  type        = string
  default     = null
  description = "Existing IAM role ARN for source→dest replication. If null, module will create one"
}

variable "destination_replication_role_arn" {
  type        = string
  default     = null
  description = "Existing IAM role ARN for dest→source replication (bidirectional only). If null, module will create one"
}

variable "source_replication_role_name" {
  type        = string
  default     = null
  description = "Name for IAM replication role (source→dest). Defaults to 'replication-role-{source_bucket_name}'"
}

variable "destination_replication_role_name" {
  type        = string
  default     = null
  description = "Name for IAM replication role (dest→source). Defaults to 'replication-role-{destination_bucket_name}'"
}

# ================================================================================
# ACCOUNT IDS
# ================================================================================

variable "source_account_id" {
  type        = string
  description = "AWS Account ID for source bucket"
}

variable "destination_account_id" {
  type        = string
  description = "AWS Account ID for destination bucket"
}

# ================================================================================
# STANDARD VARIABLES
# ================================================================================

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}
