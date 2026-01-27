data "cloudinit_config" "user_data" {
  part {
    content_type = "text/x-shellscript"
    filename     = "mount-ebs.sh"
    content      = <<EOF
#!/bin/bash
set -e

# List potential device names.
POTENTIAL_DEVICES=(/dev/xvdf /dev/nvme1n1)

# Find the first device that exists.
DATA_DEVICE=""
for DEV in "$${POTENTIAL_DEVICES[@]}"; do
  if [ -b "$DEV" ]; then
    DATA_DEVICE="$DEV"
    echo "Found device: $DATA_DEVICE"
    break
  fi
done

if [ -z "$DATA_DEVICE" ]; then
  echo "Error: No suitable data device found among: $${POTENTIAL_DEVICES[*]}"
  exit 1
fi

# Create mount point if needed.
MOUNT_POINT="/data"
if [ ! -d "$MOUNT_POINT" ]; then
  mkdir -p "$MOUNT_POINT"
fi

# Wait until the device is available.
echo "Waiting for $DATA_DEVICE to be ready..."
while [ ! -b "$DATA_DEVICE" ]; do
  sleep 1
done

# Check if the device is formatted.
if ! file -s "$DATA_DEVICE" | grep -q 'filesystem'; then
  echo "$DATA_DEVICE is not formatted. Formatting with ext4..."
  mkfs -t ext4 "$DATA_DEVICE"
else
  echo "$DATA_DEVICE already has a filesystem."
fi

# Mount the device.
echo "Mounting $DATA_DEVICE to $MOUNT_POINT..."
mount "$DATA_DEVICE" "$MOUNT_POINT"

# Add an fstab entry for persistence.
UUID=$(blkid -s UUID -o value "$DATA_DEVICE")
if [ -n "$UUID" ]; then
  if ! grep -q "$UUID" /etc/fstab; then
    echo "Adding $DATA_DEVICE (UUID=$UUID) to /etc/fstab..."
    echo "UUID=$UUID   $MOUNT_POINT   ext4   defaults,nofail   0   2" >> /etc/fstab
  else
    echo "An fstab entry for UUID=$UUID already exists."
  fi
else
  echo "Warning: Could not determine UUID for $DATA_DEVICE; not updating /etc/fstab."
fi

echo "Device $DATA_DEVICE mounted at $MOUNT_POINT successfully."
EOF
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "amazon-ssm-agent-install"
    content      = <<EOF
#!/bin/bash
cd /tmp
sudo yum install -y https://s3.amazonaws.com/ec2-downloads-windows/SSMAgent/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
EOF
  }

  dynamic "part" {
    for_each = var.custom_user_data
    content {
      content_type = part.value.content_type
      filename     = part.value.filename
      content      = part.value.content
    }
  }
}
