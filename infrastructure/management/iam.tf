data "aws_iam_policy_document" "ec2_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "jenkins" {
  for_each = toset(["controller", "agent"])

  name               = "hv-capstone-jenkins-${each.key}"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role.json

  tags = {
    Name = "hv-capstone-jenkins-${each.key}"
  }
}

resource "aws_iam_role_policy_attachment" "systems_manager" {
  for_each = aws_iam_role.jenkins

  role       = each.value.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "jenkins" {
  for_each = aws_iam_role.jenkins

  name = "hv-capstone-jenkins-${each.key}"
  role = each.value.name
}
