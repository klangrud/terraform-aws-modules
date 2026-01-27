module "ec2_scalable" {
  source = "../../../../modules/ec2_scalable"

  # General Configuration
  project_name = var.project_name
  env_short    = var.env_short
  tags         = var.tags
  environment  = var.environment
  name_prefix  = var.name_prefix

  # EC2 Instance Configuration
  ami_id                     = var.ami_id
  instance_type              = var.instance_type
  instance_count             = var.instance_count
  ec2_key_pair               = var.ec2_key_pair
  enable_detailed_monitoring = var.enable_detailed_monitoring
  disable_api_termination    = var.disable_api_termination

  # Storage Configuration
  root_block_device      = var.root_block_device
  enable_data_volume     = var.enable_data_volume
  data_volume_size       = var.data_volume_size
  additional_ebs_volumes = var.additional_ebs_volumes

  # Network Configuration
  vpc_id                      = var.vpc_id
  subnet_ids                  = var.subnet_ids
  subnet_count                = var.subnet_count
  associate_public_ip_address = var.associate_public_ip_address
  security_group_ids          = var.security_group_ids
  create_security_group       = var.create_security_group
  allowed_cidr_blocks         = var.allowed_cidr_blocks
  allowed_ssh_cidr_blocks     = var.allowed_ssh_cidr_blocks

  # IAM Configuration
  iam_instance_profile        = var.iam_instance_profile
  create_iam_instance_profile = var.create_iam_instance_profile
  additional_iam_policies     = var.additional_iam_policies

  # User Data Configuration
  enable_security_updates = var.enable_security_updates
  install_ssm_agent       = var.install_ssm_agent
  custom_user_data_parts  = var.custom_user_data_parts
}
