resource "aws_iam_role_policy" "platform_iam" {
  name = "hv-capstone-platform-iam"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageCapstoneEKSRoles"
        Effect = "Allow"
        Action = [
          "iam:CreateRole",
          "iam:GetRole",
          "iam:DeleteRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:ListRoleTags",
          "iam:ListRolePolicies",
          "iam:ListAttachedRolePolicies",
          "iam:ListInstanceProfilesForRole"
        ]
        Resource = [
          "arn:aws:iam::483510445289:role/hv-capstone-eks-cluster",
          "arn:aws:iam::483510445289:role/hv-capstone-eks-nodes"
        ]
      },
      {
        Sid    = "AttachApprovedEKSPolicies"
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = [
          "arn:aws:iam::483510445289:role/hv-capstone-eks-cluster",
          "arn:aws:iam::483510445289:role/hv-capstone-eks-nodes"
        ]
        Condition = {
          ArnEquals = {
            "iam:PolicyARN" = [
              "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
              "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
              "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPullOnly",
              "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
            ]
          }
        }
      },
      {
        Sid    = "PassCapstoneRolesToAWS"
        Effect = "Allow"
        Action = ["iam:PassRole"]
        Resource = [
          "arn:aws:iam::483510445289:role/hv-capstone-eks-cluster",
          "arn:aws:iam::483510445289:role/hv-capstone-eks-nodes"
        ]
        Condition = {
          StringEquals = {
            "iam:PassedToService" = [
              "eks.amazonaws.com",
              "ec2.amazonaws.com"
            ]
          }
        }
      },
      {
        Sid      = "CreateRequiredServiceLinkedRoles"
        Effect   = "Allow"
        Action   = ["iam:CreateServiceLinkedRole"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:AWSServiceName" = [
              "eks.amazonaws.com",
              "eks-nodegroup.amazonaws.com",
              "autoscaling.amazonaws.com"
            ]
          }
        }
      }
    ]
  })
}
