resource "tls_private_key" "ec2_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "ec2_key" {
  key_name   = "my-ec2-key"
  public_key = tls_private_key.ec2_key.public_key_openssh
}


resource "local_file" "ec2_private_key" {
  content         = tls_private_key.ec2_key.private_key_pem
  filename        = "my-ec2-key.pem"
  file_permission = "0400"
}