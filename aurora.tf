resource "aws_db_subnet_group" "aurora" {


name = "onlineboutique-db-subnet"


subnet_ids = [

 aws_subnet.private_1.id,

 aws_subnet.private_2.id

]


}

resource "aws_rds_cluster" "postgres" {

cluster_identifier = "onlineboutique-postgres"


engine = "aurora-postgresql"


engine_version = "16.4"



database_name = "products"



master_username = "admin"



master_password = password1234



db_subnet_group_name = aws_db_subnet_group.aurora.name



vpc_security_group_ids = [

aws_security_group.aurora.id

]



backup_retention_period = 7



storage_encrypted = true



skip_final_snapshot = true


}

/// Aurora needs instance 

resource "aws_rds_cluster_instance" "postgres" {


identifier = "onlineboutique-postgres-instance"


cluster_identifier = aws_rds_cluster.postgres.id


engine = aws_rds_cluster.postgres.engine


engine_version = aws_rds_cluster.postgres.engine_version


instance_class = "db.serverless"


}

// security group only EKS should access PostgreSQL

resource "aws_security_group" "aurora" {


name = "aurora-postgres"



vpc_id = aws_vpc.main.id



ingress {


from_port = 5432

to_port = 5432

protocol = "tcp"



security_groups = [

aws_security_group.eks_nodes.id

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

output "aurora_endpoint" {


value = aws_rds_cluster.postgres.endpoint


}