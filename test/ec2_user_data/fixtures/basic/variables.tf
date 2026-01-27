variable "custom_user_data" {
  description = "Custom user data scripts"
  type = map(object({
    content_type = string
    filename     = string
    content      = string
  }))
  default = {}
}
