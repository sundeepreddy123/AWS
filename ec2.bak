
resource "aws_iam_role" "ec2_role" {

  name = "EC2-SSM-Role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [

      {

        Action = "sts:AssumeRole"

        Effect = "Allow"

        Principal = {

          Service = "ec2.amazonaws.com"

        }

      }

    ]

  })

}

resource "aws_iam_role_policy_attachment" "ssm" {

  role = aws_iam_role.ec2_role.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"

}
// cloudwatch agent
resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}
// SSM parametre store access
resource "aws_ssm_parameter" "cloudwatch_config" {
  name  = "/cloudwatch/agent/config"
  type  = "String"

  value = file("amazon-cloudwatch-agent.json")
}

resource "aws_ssm_association" "cloudwatch" {
  name = "AmazonCloudWatch-ManageAgent"

  targets {
    key    = "InstanceIds"
    values = [aws_instance.ec2.id]
  }

  parameters = {
    action                        = "configure"
    mode                          = "ec2"
    optionalConfigurationSource   = "ssm"
    optionalConfigurationLocation = aws_ssm_parameter.cloudwatch_config.name
    optionalRestart               = "yes"
  }
}

resource "aws_iam_instance_profile" "profile" {

  name = "EC2-SSM-Profile"

  role = aws_iam_role.ec2_role.name

}

resource "aws_security_group" "ec2" {
  name        = "ec2-ssm-sg"
  description = "Security group for EC2 managed through SSM"
  # vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2-ssm-sg"
  }
}

resource "aws_instance" "ec2" {

  ami           = var.ec2_ami_id

  instance_type = var.ec2_instance_type

  # subnet_id = aws_subnet.public[0].id

  vpc_security_group_ids = [aws_security_group.ec2.id]

  iam_instance_profile = aws_iam_instance_profile.profile.name

  tags = {
    Name = "learning-ec2"
  }
}