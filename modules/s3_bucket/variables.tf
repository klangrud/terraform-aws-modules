variable "bucket" {
  type        = string
  description = "S3 bucket name"
}

variable "force_destroy" {
  type        = bool
  description = "When destroying this s3 bucket, it will destroy even if there are objects in the bucket"
  default     = false
}

variable "tags" {
  type        = map(string)
  description = "Tags"
}

variable "versioning" {
  type        = string
  description = "Bucket Versioning (Enabled, Suspended, or Disabled)"
  default     = "Disabled"

  validation {
    condition = contains(
      ["Enabled", "Suspended", "Disabled"],
      var.versioning
    )

    error_message = "versioning must be one of: Enabled, Suspended, or Disabled."
  }
}

variable "bucket_policies_json" {
  type        = list(string)
  description = "Statement array of JSON bucket policies to combine into single bucket policy."
  default     = []
}

variable "bucket_folders" {
  type        = list(string)
  description = "List of bucket folders to add to this bucket as aws s3 bucket objects."
  default     = []
}

variable "enable_logging" {
  type        = bool
  description = "Enable S3 access logging to a logging bucket."
  default     = true
}

variable "logging_bucket" {
  type        = string
  description = "Name of the S3 bucket for access logs. If not specified, defaults to 'logs-{region}-{account_id}'."
  default     = null
}
