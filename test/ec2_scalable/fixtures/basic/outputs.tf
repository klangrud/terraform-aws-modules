output "instance_ids" {
  description = "List of EC2 instance IDs"
  value       = module.ec2_scalable.instance_ids
}

output "instance_private_ips" {
  description = "List of private IP addresses for the EC2 instances"
  value       = module.ec2_scalable.instance_private_ips
}

output "instance_public_ips" {
  description = "List of public IP addresses for the EC2 instances (if applicable)"
  value       = module.ec2_scalable.instance_public_ips
}

output "instance_arns" {
  description = "List of EC2 instance ARNs"
  value       = module.ec2_scalable.instance_arns
}

output "security_group_id" {
  description = "Security group ID created for the EC2 instances (if created)"
  value       = module.ec2_scalable.security_group_id
}

output "iam_role_arn" {
  description = "IAM role ARN created for the EC2 instances (if created)"
  value       = module.ec2_scalable.iam_role_arn
}

output "iam_role_name" {
  description = "IAM role name created for the EC2 instances (if created)"
  value       = module.ec2_scalable.iam_role_name
}

output "iam_instance_profile_arn" {
  description = "IAM instance profile ARN created for the EC2 instances (if created)"
  value       = module.ec2_scalable.iam_instance_profile_arn
}

output "iam_instance_profile_name" {
  description = "IAM instance profile name created for the EC2 instances (if created)"
  value       = module.ec2_scalable.iam_instance_profile_name
}

output "ebs_volume_ids" {
  description = "Map of EBS volume IDs (key format: instance-volume)"
  value       = module.ec2_scalable.ebs_volume_ids
}

output "ebs_volume_arns" {
  description = "Map of EBS volume ARNs (key format: instance-volume)"
  value       = module.ec2_scalable.ebs_volume_arns
}

output "instance_details" {
  description = "Detailed information about each EC2 instance"
  value       = module.ec2_scalable.instance_details
}
