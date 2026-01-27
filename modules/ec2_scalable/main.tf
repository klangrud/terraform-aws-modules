############################################
# Main Configuration
# - Defining Local Variables and Tags
############################################

locals {
  name_prefix = var.name_prefix != "" ? var.name_prefix : "${var.project_name}-${var.env_short}"

  extra_tags = {
    Name        = var.project_name
    Application = var.project_name
    Project     = var.project_name
    Environment = var.env_short
    ManagedBy   = "terraform"
  }

  tags = merge(var.tags, local.extra_tags)

  # Prepare EBS volumes including optional /data volume
  all_ebs_volumes = concat(
    var.enable_data_volume ? [{
      device_name = "/dev/sdf"
      mount_point = "/data"
      volume_size = var.data_volume_size
      volume_type = "gp3"
      iops        = 3000
      throughput  = 125
      encrypted   = true
      filesystem  = "ext4"
    }] : [],
    var.additional_ebs_volumes
  )

  # Create a flattened list of instance-volume combinations for dynamic EBS creation
  instance_volume_map = flatten([
    for idx in range(var.instance_count) : [
      for vol_idx, vol in local.all_ebs_volumes : {
        instance_index = idx
        volume_index   = vol_idx
        instance_key   = "instance-${idx}"
        volume_key     = "${idx}-${vol_idx}"
        device_name    = vol.device_name
        mount_point    = vol.mount_point
        volume_size    = vol.volume_size
        volume_type    = vol.volume_type
        iops           = vol.iops
        throughput     = vol.throughput
        encrypted      = vol.encrypted
        filesystem     = vol.filesystem
      }
    ]
  ])

  # Map of instance volumes for easy lookup
  instance_volumes = {
    for iv in local.instance_volume_map : iv.volume_key => iv
  }
}

############################################
# Data Sources
############################################

data "aws_subnet" "selected" {
  # Use subnet_count when provided so count is known at plan time.
  count = coalesce(var.subnet_count, length(var.subnet_ids))

  id = var.subnet_ids[count.index]
}

############################################
# Security Group (Optional)
############################################

resource "aws_security_group" "ec2_sg" {
  count = var.create_security_group ? 1 : 0

  name_prefix = "${local.name_prefix}-ec2-"
  description = "Security group for ${local.name_prefix} EC2 instances"
  vpc_id      = var.vpc_id

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  # SSH access
  dynamic "ingress" {
    for_each = length(var.allowed_ssh_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = var.allowed_ssh_cidr_blocks
      description = "SSH access"
    }
  }

  # Additional CIDR access
  dynamic "ingress" {
    for_each = length(var.allowed_cidr_blocks) > 0 ? [1] : []
    content {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = var.allowed_cidr_blocks
      description = "Allow traffic from specified CIDR blocks"
    }
  }

  tags = merge(
    local.tags,
    {
      Name = "${local.name_prefix}-ec2-sg"
    }
  )

  lifecycle {
    create_before_destroy = true
  }
}

############################################
# IAM Instance Profile (Optional)
############################################

resource "aws_iam_role" "ec2_role" {
  count = var.create_iam_instance_profile && var.iam_instance_profile == null ? 1 : 0

  name_prefix = "${local.name_prefix}-ec2-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ssm_policy" {
  count = var.create_iam_instance_profile && var.iam_instance_profile == null ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "cloudwatch_policy" {
  count = var.create_iam_instance_profile && var.iam_instance_profile == null ? 1 : 0

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

resource "aws_iam_role_policy_attachment" "additional_policies" {
  for_each = var.create_iam_instance_profile && var.iam_instance_profile == null ? toset(var.additional_iam_policies) : toset([])

  role       = aws_iam_role.ec2_role[0].name
  policy_arn = each.value
}

resource "aws_iam_instance_profile" "ec2_profile" {
  count = var.create_iam_instance_profile && var.iam_instance_profile == null ? 1 : 0

  name_prefix = "${local.name_prefix}-ec2-"
  role        = aws_iam_role.ec2_role[0].name

  tags = local.tags
}

resource "aws_iam_role_policy" "ssm_s3_encryption_read" {
  count = var.create_iam_instance_profile && var.iam_instance_profile == null ? 1 : 0

  name = "${local.name_prefix}-ssm-s3-encryption-read"
  role = aws_iam_role.ec2_role[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowS3GetEncryptionConfiguration"
        Effect = "Allow"
        Action = [
          "s3:GetEncryptionConfiguration"
        ]
        Resource = "*"
      }
    ]
  })
}
