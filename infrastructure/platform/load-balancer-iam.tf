data "aws_iam_policy_document" "load_balancer_controller_trust" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.platform.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(aws_eks_cluster.platform.identity[0].oidc[0].issuer, "https://")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "${trimprefix(aws_eks_cluster.platform.identity[0].oidc[0].issuer, "https://")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "aws_iam_role" "load_balancer_controller" {
  name               = "hv-capstone-load-balancer-controller"
  assume_role_policy = data.aws_iam_policy_document.load_balancer_controller_trust.json
}

resource "aws_iam_policy" "load_balancer_controller" {
  name = "hv-capstone-load-balancer-controller"

  policy = file("${path.module}/policies/aws-load-balancer-controller.json")
}

resource "aws_iam_role_policy_attachment" "load_balancer_controller" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}
