output "repo_name" {
  description = "Name of the ECR repository"
  value       = module.elastic_container_registry.repo_name
}
