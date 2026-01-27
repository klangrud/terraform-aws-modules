############################################
# Outputs
############################################

output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = aws_instance.ec2[*].id
}

output "instance_private_ips" {
  description = "List of private IP addresses for the EC2 instances"
  value       = aws_instance.ec2[*].private_ip
}

output "instance_public_ips" {
  description = "List of public IP addresses for the EC2 instances (if applicable)"
  value       = aws_instance.ec2[*].public_ip
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = aws_instance.ec2[*].arn
}

output "security_group_id" {
  description = "Security group ID created for the EC2 instances (if created)"
  value       = var.create_security_group ? aws_security_group.ec2_sg[0].id : null
}

output "iam_role_arn" {
  description = "IAM role ARN created for the EC2 instances (if created)"
  value       = var.create_iam_instance_profile && var.iam_instance_profile == null ? aws_iam_role.ec2_role[0].arn : null
}

output "iam_role_name" {
  description = "IAM role name created for the EC2 instances (if created)"
  value       = var.create_iam_instance_profile && var.iam_instance_profile == null ? aws_iam_role.ec2_role[0].name : null
}

output "iam_instance_profile_arn" {
  description = "IAM instance profile ARN created for the EC2 instances (if created)"
  value       = var.create_iam_instance_profile && var.iam_instance_profile == null ? aws_iam_instance_profile.ec2_profile[0].arn : null
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name created for the EC2 instances (if created)"
  value       = var.create_iam_instance_profile && var.iam_instance_profile == null ? aws_iam_instance_profile.ec2_profile[0].name : null
}

output "ebs_volume_ids" {
  description = "Map of EBS volume IDs (key format: instance-volume)"
  value       = { for k, v in aws_ebs_volume.additional : k => v.id }
}

output "ebs_volume_arns" {
  description = "Map of EBS volume ARNs (key format: instance-volume)"
  value       = { for k, v in aws_ebs_volume.additional : k => v.arn }
}

output "instance_details" {
  description = "Detailed information about each EC2 instance"
  value = [
    for idx, instance in aws_instance.ec2 : {
      index      = idx
      id         = instance.id
      arn        = instance.arn
      private_ip = instance.private_ip
      public_ip  = instance.public_ip
      subnet_id  = instance.subnet_id
      az         = instance.availability_zone
    }
  ]
}
