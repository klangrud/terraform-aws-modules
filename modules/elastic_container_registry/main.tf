### Module related to Elastic Container Registry ECR

resource "aws_ecr_repository" "repo" {
  name                 = var.aws_ecr_repository_name
  image_tag_mutability = "IMMUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository_policy" "policy" {
  repository = aws_ecr_repository.repo.name
  policy     = data.aws_iam_policy_document.policy_document.json
}
