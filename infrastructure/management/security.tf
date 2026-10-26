resource "aws_security_group" "jenkins_controller" {
  name_prefix = "hv-capstone-controller-"
  description = "Administrative access to the Jenkins controller"
  vpc_id      = aws_vpc.management.id

  ingress {
    description = "SSH from administrator"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description = "Jenkins web interface from administrator"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  egress {
    description = "Outbound access for software downloads and AWS APIs"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hv-capstone-controller-sg"
  }
}

resource "aws_security_group" "jenkins_agent" {
  name_prefix = "hv-capstone-agent-"
  description = "SSH access to the Jenkins build agent"
  vpc_id      = aws_vpc.management.id

  ingress {
    description = "SSH from administrator for initial configuration"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  ingress {
    description     = "SSH from Jenkins controller"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.jenkins_controller.id]
  }

  egress {
    description = "Outbound access for builds and deployments"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "hv-capstone-agent-sg"
  }
}
