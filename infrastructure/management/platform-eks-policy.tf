resource "aws_iam_role_policy" "platform_eks" {
  name = "hv-capstone-platform-eks"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageCapstoneEKS"
        Effect = "Allow"
        Action = [
          "eks:CreateCluster",
          "eks:DescribeCluster",
          "eks:UpdateClusterConfig",
          "eks:UpdateClusterVersion",
          "eks:DeleteCluster",
          "eks:DescribeUpdate",
          "eks:CreateNodegroup",
          "eks:DescribeNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
          "eks:DeleteNodegroup",
          "eks:ListNodegroups",
          "eks:CreateAccessEntry",
          "eks:DescribeAccessEntry",
          "eks:UpdateAccessEntry",
          "eks:DeleteAccessEntry",
          "eks:ListAccessEntries",
          "eks:AssociateAccessPolicy",
          "eks:DisassociateAccessPolicy",
          "eks:ListAssociatedAccessPolicies",
          "eks:TagResource",
          "eks:UntagResource",
          "eks:ListTagsForResource"
        ]
        Resource = [
          "arn:aws:eks:ap-south-1:483510445289:cluster/hv-capstone-dev",
          "arn:aws:eks:ap-south-1:483510445289:nodegroup/hv-capstone-dev/*",
          "arn:aws:eks:ap-south-1:483510445289:access-entry/hv-capstone-dev/*"
        ]
      }
    ]
  })
}
