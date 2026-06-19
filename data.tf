data "aws_vpc" "main" {
  id = aws_vpc.main.id
}

data "aws_subnets" "private" {

  filter {
    name   = "vpc-id"
    values = [aws_vpc.main.id]
  }

  tags = {
    Tier = "Private"
  }
}