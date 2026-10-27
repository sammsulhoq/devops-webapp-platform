resource "aws_iam_role_policy" "platform_ecr" {
  name = "hv-capstone-platform-ecr"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageCapstoneRepository"
        Effect = "Allow"
        Action = [
          "ecr:CreateRepository",
          "ecr:DescribeRepositories",
          "ecr:DeleteRepository",
          "ecr:GetRepositoryPolicy",
          "ecr:ListTagsForResource",
          "ecr:TagResource",
          "ecr:UntagResource",
          "ecr:PutImageScanningConfiguration",
          "ecr:PutImageTagMutability",
          "ecr:GetLifecyclePolicy",
          "ecr:PutLifecyclePolicy",
          "ecr:DeleteLifecyclePolicy"
        ]
        Resource = "arn:aws:ecr:ap-south-1:483510445289:repository/hv-capstone-app"
      }
    ]
  })
}
