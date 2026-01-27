output "user_data_content" {
  description = "The rendered cloud-init user data content"
  value       = data.cloudinit_config.user_data.rendered
}
