output "repo_name" {
  description = "The name of the ECR repository"
  value       = aws_ecr_repository.repo.name
}
