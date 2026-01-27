data "aws_iam_policy_document" "policy_document" {
  statement {
    sid = "Add full ECR access to ${aws_ecr_repository.repo.name} repository"

    effect = "Allow"

    principals {
      identifiers = ["*"]
      type        = "AWS"
    }

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:GetLifecyclePolicy",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
  }
}
