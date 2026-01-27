variable "env" {
  description = "Environment name"
  type        = string
  default     = "test"
}

variable "saml_metadata_document" {
  description = "SAML metadata XML document"
  type        = string
  default     = <<-EOF
<?xml version="1.0" encoding="UTF-8"?>
<md:EntityDescriptor xmlns:md="urn:oasis:names:tc:SAML:2.0:metadata" entityID="http://www.okta.com/test">
  <md:IDPSSODescriptor WantAuthnRequestsSigned="false" protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <md:KeyDescriptor use="signing">
      <ds:KeyInfo xmlns:ds="http://www.w3.org/2000/09/xmldsig#">
        <ds:X509Data>
          <ds:X509Certificate>MIIDpDCCAoygAwIBAgIGAX0example</ds:X509Certificate>
        </ds:X509Data>
      </ds:KeyInfo>
    </md:KeyDescriptor>
    <md:SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://test.okta.com/app/test/sso/saml"/>
  </md:IDPSSODescriptor>
</md:EntityDescriptor>
EOF
}

variable "provider_name" {
  description = "Name for the SAML provider"
  type        = string
  default     = "Okta"
}

variable "create_role_discovery_user" {
  description = "Create role discovery user"
  type        = bool
  default     = false
}

variable "role_discovery_user_name" {
  description = "Role discovery user name"
  type        = string
  default     = "OktaSSOUser"
}

variable "tags" {
  description = "Tags to apply"
  type        = map(string)
  default = {
    Environment = "test"
    ManagedBy   = "terraform"
  }
}
