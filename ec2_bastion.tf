resource "tls_private_key" "bastion_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_key_pair" "bastion_key" {
  key_name   = "linux-bastion-key"
  public_key = tls_private_key.bastion_key.public_key_openssh
}


resource "local_file" "bastion_pem" {

  content  = tls_private_key.bastion_key.private_key_pem

  filename = "linux-bastion-key.pem"

  file_permission = "0400"
}

resource "aws_security_group" "bastion_sg" {

  name = "linux-bastion-sg"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "SSH access"

    from_port = 22
    to_port = 22
    protocol = "tcp"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }


  egress {

    from_port = 0
    to_port = 0
    protocol = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}


resource "aws_instance" "linux_bastion" {


  ami = var.ec2_ami_id


  instance_type = var.ec2_instance_type


  subnet_id = aws_subnet.public[0].id


  associate_public_ip_address = true


  key_name = aws_key_pair.bastion_key.key_name


  vpc_security_group_ids = [
    aws_security_group.bastion_sg.id
  ]


  tags = {

    Name = "linux-bastion"

  }

}