
resource "aws_instance" "ec2" {

  ami           = var.ec2_ami_id

  instance_type = var.ec2_instance_type

  subnet_id = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name

  tags = {
    Name = "learning-ec2"
  }
}