output "repo_name" {
  description = "The name of the ECR repository"
  value       = data.aws_ecr_image.image.repository_name
}

output "image_tag" {
  description = "The tag of the ECR image"
  value       = data.aws_ecr_image.image.image_tags[0]
}
