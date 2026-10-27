data "aws_iam_role" "platform_operator" {
  name = "AWSReservedSSO_AdministratorAccess_b6cf4a592982cb4c"
}

resource "aws_iam_role_policy" "platform_plan" {
  name = "hv-capstone-platform-plan"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "InspectNetworkAndAgent"
        Effect = "Allow"
        Action = [
          "ec2:Describe*"
        ]
        Resource = "*"
      },
      {
        Sid    = "ReadProjectRoles"
        Effect = "Allow"
        Action = [
          "iam:GetRole"
        ]
        Resource = [
          data.aws_iam_role.platform_operator.arn,
          aws_iam_role.jenkins["agent"].arn
        ]
      },
      {
        Sid    = "ListTerraformStateBucket"
        Effect = "Allow"
        Action = [
          "s3:GetBucketLocation",
          "s3:ListBucket"
        ]
        Resource = "arn:aws:s3:::hv-capstone-tfstate-483510445289-ap-south-1"
      },
      {
        Sid    = "ReadPlatformState"
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::hv-capstone-tfstate-483510445289-ap-south-1/platform/dev/terraform.tfstate"
      },
      {
        Sid    = "ManagePlatformStateLock"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = "arn:aws:s3:::hv-capstone-tfstate-483510445289-ap-south-1/platform/dev/terraform.tfstate.tflock"
      }
    ]
  })
}
