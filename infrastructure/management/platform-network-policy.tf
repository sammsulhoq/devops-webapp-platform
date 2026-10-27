resource "aws_iam_role_policy" "platform_network" {
  name = "hv-capstone-platform-network"
  role = aws_iam_role.jenkins["agent"].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "CreateTaggedPlatformNetwork"
        Effect = "Allow"
        Action = [
          "ec2:CreateVpc",
          "ec2:CreateSubnet",
          "ec2:CreateInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:AllocateAddress",
          "ec2:CreateNatGateway"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion"        = "ap-south-1"
            "aws:RequestTag/Project"     = "devops-webapp-platform"
            "aws:RequestTag/Environment" = "dev"
          }
        }
      },
      {
        Sid    = "ManageTaggedPlatformNetwork"
        Effect = "Allow"
        Action = [
          "ec2:CreateSubnet",
          "ec2:CreateRouteTable",
          "ec2:CreateNatGateway",
          "ec2:ModifyVpcAttribute",
          "ec2:ModifySubnetAttribute",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:ReplaceRouteTableAssociation",
          "ec2:DisassociateRouteTable",
          "ec2:DeleteNatGateway",
          "ec2:ReleaseAddress",
          "ec2:DeleteRouteTable",
          "ec2:DeleteInternetGateway",
          "ec2:DeleteSubnet",
          "ec2:DeleteVpc"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion"         = "ap-south-1"
            "aws:ResourceTag/Project"     = "devops-webapp-platform"
            "aws:ResourceTag/Environment" = "dev"
          }
        }
      },
      {
        Sid      = "TagNetworkResourcesOnCreation"
        Effect   = "Allow"
        Action   = ["ec2:CreateTags"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:RequestedRegion" = "ap-south-1"
            "ec2:CreateAction" = [
              "CreateVpc",
              "CreateSubnet",
              "CreateInternetGateway",
              "CreateRouteTable",
              "AllocateAddress",
              "CreateNatGateway"
            ]
          }
        }
      }
    ]
  })
}
