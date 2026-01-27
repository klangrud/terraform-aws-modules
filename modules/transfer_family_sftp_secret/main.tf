# ---------------------------------------------------------------------------------------------------------------------
# SFTP User Secret for AWS Transfer Family
# Generates and stores SFTP credentials in AWS Secrets Manager
# ---------------------------------------------------------------------------------------------------------------------

resource "random_password" "sftp" {
  length  = var.password_length
  special = true
  # Only use special characters allowed by AWS Transfer Family
  override_special = "_+=,.@-"

  keepers = {
    rotation = var.password_rotation
  }
}

resource "aws_secretsmanager_secret" "sftp" {
  name        = var.secret_name
  description = var.description
  tags        = var.tags
}

resource "aws_secretsmanager_secret_version" "sftp" {
  secret_id = aws_secretsmanager_secret.sftp.id

  secret_string = jsonencode({
    Role              = var.role_arn
    HomeDirectory     = var.home_directory
    AcceptedIpNetwork = var.accepted_ip_network
    Password          = random_password.sftp.result
  })
}
