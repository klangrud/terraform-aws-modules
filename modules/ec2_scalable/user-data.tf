############################################
# Cloud-Init User Data Configuration
# - Security Updates
# - EBS Volume Mounting
# - SSM Agent Installation
# - Custom User Data Parts
############################################

data "cloudinit_config" "user_data" {
  count = var.instance_count

  gzip          = true
  base64_encode = true

  # Part 1: Apply security updates on first boot
  dynamic "part" {
    for_each = var.enable_security_updates ? [1] : []
    content {
      content_type = "text/x-shellscript"
      filename     = "00-security-updates.sh"
      content      = <<-EOF
        #!/bin/bash
        set -e
        echo "==> Applying security updates..."

        # Detect OS type
        if [ -f /etc/os-release ]; then
          . /etc/os-release
          OS=$ID
        fi

        # Apply updates based on OS
        case "$OS" in
          amzn|amazonlinux)
            echo "Detected Amazon Linux"
            yum update -y --security
            ;;
          ubuntu|debian)
            echo "Detected Debian-based OS"
            apt-get update
            DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
            ;;
          rhel|centos|rocky)
            echo "Detected RHEL-based OS"
            yum update -y --security
            ;;
          *)
            echo "Unknown OS: $OS - skipping security updates"
            ;;
        esac

        echo "==> Security updates completed"
      EOF
    }
  }

  # Part 2: Mount EBS volumes dynamically
  dynamic "part" {
    for_each = length(local.all_ebs_volumes) > 0 ? [1] : []
    content {
      content_type = "text/x-shellscript"
      filename     = "10-mount-ebs-volumes.sh"
      content      = <<-EOF
        #!/bin/bash
        set -e

        echo "==> Starting EBS volume mounting script..."

        # Function to wait for device
        wait_for_device() {
          local device=$1
          local max_wait=60
          local waited=0

          echo "Waiting for device $device to be available..."
          while [ ! -b "$device" ] && [ $waited -lt $max_wait ]; do
            sleep 1
            waited=$((waited + 1))
          done

          if [ ! -b "$device" ]; then
            echo "ERROR: Device $device not available after $max_wait seconds"
            return 1
          fi

          echo "Device $device is available"
          return 0
        }

        # Function to get actual device name (handles NVMe naming)
        get_actual_device() {
          local requested_device=$1

          # Check if the requested device exists
          if [ -b "$requested_device" ]; then
            echo "$requested_device"
            return 0
          fi

          # For NVMe instances, map device names
          case "$requested_device" in
            /dev/sdf|/dev/xvdf)
              if [ -b /dev/nvme1n1 ]; then echo "/dev/nvme1n1"; return 0; fi
              ;;
            /dev/sdg|/dev/xvdg)
              if [ -b /dev/nvme2n1 ]; then echo "/dev/nvme2n1"; return 0; fi
              ;;
            /dev/sdh|/dev/xvdh)
              if [ -b /dev/nvme3n1 ]; then echo "/dev/nvme3n1"; return 0; fi
              ;;
            /dev/sdi|/dev/xvdi)
              if [ -b /dev/nvme4n1 ]; then echo "/dev/nvme4n1"; return 0; fi
              ;;
          esac

          echo "$requested_device"
          return 0
        }

        # Mount each volume
        %{for idx, vol in local.all_ebs_volumes~}
        echo "==> Processing volume ${idx + 1}/${length(local.all_ebs_volumes)}: ${vol.device_name} -> ${vol.mount_point}"

        REQUESTED_DEVICE="${vol.device_name}"
        ACTUAL_DEVICE=$(get_actual_device "$REQUESTED_DEVICE")
        MOUNT_POINT="${vol.mount_point}"
        FILESYSTEM="${vol.filesystem}"

        echo "Requested device: $REQUESTED_DEVICE"
        echo "Actual device: $ACTUAL_DEVICE"
        echo "Mount point: $MOUNT_POINT"
        echo "Filesystem: $FILESYSTEM"

        # Wait for device to be available
        if ! wait_for_device "$ACTUAL_DEVICE"; then
          echo "ERROR: Could not mount $ACTUAL_DEVICE to $MOUNT_POINT"
          continue
        fi

        # Create mount point if it doesn't exist
        if [ ! -d "$MOUNT_POINT" ]; then
          echo "Creating mount point: $MOUNT_POINT"
          mkdir -p "$MOUNT_POINT"
        fi

        # Check if device has a filesystem
        if ! blkid "$ACTUAL_DEVICE" > /dev/null 2>&1; then
          echo "No filesystem detected on $ACTUAL_DEVICE. Creating $FILESYSTEM filesystem..."
          mkfs -t "$FILESYSTEM" "$ACTUAL_DEVICE"
        else
          echo "Filesystem already exists on $ACTUAL_DEVICE"
        fi

        # Mount the device
        if ! mountpoint -q "$MOUNT_POINT"; then
          echo "Mounting $ACTUAL_DEVICE to $MOUNT_POINT..."
          mount "$ACTUAL_DEVICE" "$MOUNT_POINT"
          echo "Mount successful"
        else
          echo "$MOUNT_POINT is already mounted"
        fi

        # Add to fstab for persistence (using UUID)
        UUID=$(blkid -s UUID -o value "$ACTUAL_DEVICE")
        if [ -n "$UUID" ]; then
          if ! grep -q "$UUID" /etc/fstab; then
            echo "Adding $ACTUAL_DEVICE (UUID=$UUID) to /etc/fstab..."
            echo "UUID=$UUID   $MOUNT_POINT   $FILESYSTEM   defaults,nofail   0   2" >> /etc/fstab
          else
            echo "fstab entry for UUID=$UUID already exists"
          fi
        else
          echo "WARNING: Could not determine UUID for $ACTUAL_DEVICE"
        fi

        echo "==> Volume ${idx + 1} processing complete"
        echo ""

        %{endfor~}

        echo "==> All EBS volumes processed successfully"
      EOF
    }
  }

  # Part 3: Install SSM Agent
  dynamic "part" {
    for_each = var.install_ssm_agent ? [1] : []
    content {
      content_type = "text/x-shellscript"
      filename     = "20-install-ssm-agent.sh"
      content      = <<-EOF
        #!/bin/bash
        set -e
        echo "==> Installing AWS SSM Agent..."

        cd /tmp

        # Detect OS and install accordingly
        if [ -f /etc/os-release ]; then
          . /etc/os-release
          OS=$ID
        fi

        case "$OS" in
          amzn|amazonlinux)
            yum install -y amazon-ssm-agent
            ;;
          ubuntu|debian)
            snap install amazon-ssm-agent --classic
            ;;
          *)
            # Generic installation
            yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm || \
            snap install amazon-ssm-agent --classic
            ;;
        esac

        systemctl enable amazon-ssm-agent
        systemctl start amazon-ssm-agent

        echo "==> SSM Agent installation complete"
      EOF
    }
  }

  # Part 4: Custom user data parts
  dynamic "part" {
    for_each = var.custom_user_data_parts
    content {
      content_type = part.value.content_type
      filename     = part.value.filename
      content      = part.value.content
    }
  }
}
