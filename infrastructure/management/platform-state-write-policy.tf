resource "aws_iam_role_policy" "platform_state_write" {
  name = "hv-capstone-platform-state-write"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "WritePlatformTerraformState"
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "arn:aws:s3:::hv-capstone-tfstate-483510445289-ap-south-1/platform/dev/terraform.tfstate"
      }
    ]
  })
}
