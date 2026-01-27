provider "cloudinit" {}

module "ec2_user_data" {
  source = "../../../../modules/ec2_user_data"

  custom_user_data = var.custom_user_data
}
