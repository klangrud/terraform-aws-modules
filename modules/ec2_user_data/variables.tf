variable "custom_user_data" {
  description = "Map of custom user data scripts to append to cloud-init"
  type = map(object({
    content_type = string
    filename     = string
    content      = string
  }))
  default = {}
}
