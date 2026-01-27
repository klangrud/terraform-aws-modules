output "user_data_content" {
  description = "The rendered cloud-init user data"
  value       = module.ec2_user_data.user_data_content
}
