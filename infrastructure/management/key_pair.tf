resource "aws_key_pair" "jenkins" {
  key_name   = "hv-capstone-jenkins"
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = {
    Name = "hv-capstone-jenkins"
  }
}
