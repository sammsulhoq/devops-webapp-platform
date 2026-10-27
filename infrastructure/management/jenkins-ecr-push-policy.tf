resource "aws_iam_role_policy" "jenkins_ecr_push" {
  name = "hv-capstone-jenkins-ecr-push"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "GetECRAuthorizationToken"
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Sid    = "PushCapstoneImages"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "arn:aws:ecr:ap-south-1:483510445289:repository/hv-capstone-app"
      }
    ]
  })
}
