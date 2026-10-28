resource "aws_iam_role_policy" "jenkins_load_balancer" {
  name = "hv-capstone-jenkins-load-balancer"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ManageClusterOIDCProvider"
        Effect = "Allow"
        Action = [
          "iam:CreateOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:UpdateOpenIDConnectProviderThumbprint",
          "iam:AddClientIDToOpenIDConnectProvider",
          "iam:RemoveClientIDFromOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider",
          "iam:ListOpenIDConnectProviderTags"
        ]
        Resource = "arn:aws:iam::483510445289:oidc-provider/oidc.eks.ap-south-1.amazonaws.com/id/CA945E63E3EE717EBEC0781C321B0228"
      },
      {
        Sid    = "ManageControllerRole"
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
        Resource = "arn:aws:iam::483510445289:role/hv-capstone-load-balancer-controller"
      },
      {
        Sid    = "ManageControllerPolicy"
        Effect = "Allow"
        Action = [
          "iam:CreatePolicy",
          "iam:GetPolicy",
          "iam:GetPolicyVersion",
          "iam:ListPolicyVersions",
          "iam:CreatePolicyVersion",
          "iam:SetDefaultPolicyVersion",
          "iam:DeletePolicyVersion",
          "iam:DeletePolicy",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:ListPolicyTags"
        ]
        Resource = "arn:aws:iam::483510445289:policy/hv-capstone-load-balancer-controller"
      },
      {
        Sid    = "AttachControllerPolicy"
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy"
        ]
        Resource = "arn:aws:iam::483510445289:role/hv-capstone-load-balancer-controller"
        Condition = {
          ArnEquals = {
            "iam:PolicyARN" = "arn:aws:iam::483510445289:policy/hv-capstone-load-balancer-controller"
          }
        }
      }
    ]
  })
}
