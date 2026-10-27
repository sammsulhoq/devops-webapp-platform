resource "aws_iam_role_policy" "jenkins_eks_addon" {
  name = "hv-capstone-jenkins-eks-addon"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "CreateClusterAddons"
        Effect   = "Allow"
        Action   = ["eks:CreateAddon"]
        Resource = "arn:aws:eks:ap-south-1:483510445289:cluster/hv-capstone-dev"
      },
      {
        Sid    = "ManageMetricsServer"
        Effect = "Allow"
        Action = [
          "eks:DescribeAddon",
          "eks:UpdateAddon",
          "eks:DeleteAddon",
          "eks:DescribeUpdate",
          "eks:ListTagsForResource",
          "eks:TagResource",
          "eks:UntagResource"
        ]
        Resource = "arn:aws:eks:ap-south-1:483510445289:addon/hv-capstone-dev/metrics-server/*"
      }
    ]
  })
}
