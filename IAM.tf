
// role for ssm
resource "aws_iam_role" "ec2_ssm_role" {

  name = "ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "ec2.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}
// policy attachment for ssm role

resource "aws_iam_role_policy_attachment" "ssm" {

  role       = aws_iam_role.ec2_ssm_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

// instance profile for ssm role
resource "aws_iam_instance_profile" "ec2_ssm" {

  name = "ec2-ssm-profile"

  role = aws_iam_role.ec2_ssm_role.name
}

///security group for ssm role
resource "aws_security_group" "ec2" {

  name   = "ec2-sg"

  vpc_id = aws_vpc.main.id

  ingress {

    description = "SSH"

    from_port = 22
    to_port   = 22

    protocol = "tcp"

    cidr_blocks = [var.vpc_cidr]
  }

  egress {

    from_port = 0
    to_port   = 0
    protocol  = "-1"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }
}