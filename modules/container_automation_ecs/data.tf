data "aws_ecr_image" "image" {
  repository_name = var.aws_ecr_image_repository_name
  most_recent     = true
}
