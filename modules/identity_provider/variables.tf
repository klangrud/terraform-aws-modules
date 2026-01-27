# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "env" {
  description = "Environment name (e.g., prod, dev, staging). Used in resource naming."
  type        = string
}

variable "saml_metadata_document" {
  description = "SAML Metadata XML document from your identity provider (Okta, Azure AD, Google Workspace, etc.)"
  type        = string
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# ---------------------------------------------------------------------------------------------------------------------

variable "provider_name" {
  description = "Name for the SAML identity provider. Will be suffixed with environment."
  type        = string
  default     = "saml-idp"
}

variable "create_role_discovery_user" {
  description = "Create an IAM user for IdP role discovery (required for Okta, optional for others)."
  type        = bool
  default     = false
}

variable "role_discovery_user_name" {
  description = "Name for the IAM user used by IdP for role discovery. Only used if create_role_discovery_user is true."
  type        = string
  default     = "SSOServiceUser"
}

variable "tags" {
  description = "Tags to apply to all resources."
  type        = map(string)
  default     = {}
}
