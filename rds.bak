resource "aws_security_group" "rds_sg" {

  name = "rds-private-sg"

  vpc_id = aws_vpc.main.id


  ingress {

    description = "mysql from bastion"

    from_port = 3306

    to_port = 3306

    protocol = "tcp"

    security_groups = [
      aws_security_group.bastion_sg.id
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

resource "aws_db_instance" "mysql" {


  identifier = "private-mysql-db"


  engine = "mysql"

  engine_version = "8.0"


  instance_class = "db.t3.micro"


  allocated_storage = 20


  username = "admin"

  password = "Password12345!"


  vpc_security_group_ids = [aws_security_group.bastion_sg]


  publicly_accessible = false


  skip_final_snapshot = true


  tags = {

    Name = "private-rds"

  }
}
