############################################
# EC2 Instance Configuration
# - Multiple instances with count-based deployment
# - Distributed across provided subnets
# - User data with EBS auto-mounting
############################################

resource "aws_instance" "ec2" {
  count = var.instance_count

  ami                         = var.ami_id
  instance_type               = var.instance_type
  key_name                    = var.ec2_key_pair
  subnet_id                   = var.subnet_ids[count.index % length(var.subnet_ids)]
  associate_public_ip_address = var.associate_public_ip_address
  monitoring                  = var.enable_detailed_monitoring
  disable_api_termination     = var.disable_api_termination

  # IAM Instance Profile
  iam_instance_profile = (
    var.iam_instance_profile != null ? var.iam_instance_profile :
    var.create_iam_instance_profile ? aws_iam_instance_profile.ec2_profile[0].name :
    null
  )

  # User data with cloud-init
  user_data_base64 = data.cloudinit_config.user_data[count.index].rendered

  # Security Groups
  vpc_security_group_ids = concat(
    var.security_group_ids,
    var.create_security_group ? [aws_security_group.ec2_sg[0].id] : []
  )

  ############################################
  # Root Block Device (Primary Storage)
  ############################################
  root_block_device {
    volume_type           = var.root_block_device.volume_type
    volume_size           = var.root_block_device.volume_size
    encrypted             = var.root_block_device.encrypted
    iops                  = var.root_block_device.iops
    throughput            = var.root_block_device.throughput
    delete_on_termination = true

    tags = merge(
      local.tags,
      {
        Name = "${local.name_prefix}-${count.index}-root"
        Type = "root"
      }
    )
  }

  ############################################
  # Metadata Options (IMDSv2)
  ############################################
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required" # Enforce IMDSv2
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  ############################################
  # Tags
  ############################################
  tags = merge(
    local.tags,
    {
      Name      = "${local.name_prefix}-${count.index}"
      Instance  = count.index
      ManagedBy = "terraform"
    }
  )

  lifecycle {
    ignore_changes = [
      ami, # Ignore AMI changes to prevent recreation on AMI updates
      user_data_base64
    ]
  }

  depends_on = [
    aws_iam_instance_profile.ec2_profile
  ]
}

############################################
# Additional EBS Volumes
# - Dynamically created based on configuration
# - Automatically formatted and mounted via user-data
############################################

resource "aws_ebs_volume" "additional" {
  for_each = local.instance_volumes

  availability_zone = data.aws_subnet.selected[each.value.instance_index % length(var.subnet_ids)].availability_zone
  size              = each.value.volume_size
  type              = each.value.volume_type
  iops              = each.value.iops
  throughput        = each.value.throughput
  encrypted         = each.value.encrypted

  tags = merge(
    local.tags,
    {
      Name        = "${local.name_prefix}-${each.value.instance_index}-vol-${each.value.volume_index}"
      Instance    = each.value.instance_index
      MountPoint  = each.value.mount_point
      DeviceName  = each.value.device_name
      VolumeIndex = each.value.volume_index
    }
  )
}

############################################
# EBS Volume Attachments
############################################

resource "aws_volume_attachment" "additional" {
  for_each = local.instance_volumes

  device_name = each.value.device_name
  volume_id   = aws_ebs_volume.additional[each.key].id
  instance_id = aws_instance.ec2[each.value.instance_index].id

  # Prevent detachment on destroy
  skip_destroy = false

  # Force detachment if needed
  force_detach = true
}
