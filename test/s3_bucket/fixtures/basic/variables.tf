variable "bucket" {
  description = "S3 bucket name"
  type        = string
  default     = "test-bucket-unit-test-123456"
}

variable "force_destroy" {
  description = "Force destroy bucket"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}

variable "versioning" {
  description = "Versioning status"
  type        = string
  default     = "Disabled"
}

variable "bucket_policies_json" {
  description = "Bucket policies"
  type        = list(string)
  default     = []
}

variable "bucket_folders" {
  description = "Bucket folders to create"
  type        = list(string)
  default     = []
}

variable "enable_logging" {
  description = "Enable access logging"
  type        = bool
  default     = false
}

variable "logging_bucket" {
  description = "Logging bucket name"
  type        = string
  default     = null
}
