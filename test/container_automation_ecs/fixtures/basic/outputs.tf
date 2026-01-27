output "repo_name" {
  description = "Name of the ECR repository"
  value       = module.container_automation_ecs.repo_name
}

output "image_tag" {
  description = "Tag of the ECR image"
  value       = module.container_automation_ecs.image_tag
}
