output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

output "az_zones" {
  value = aws_subnet.public[*].availability_zone
}

# output "cluster_name" {
#   value = aws_eks_cluster.dev.name
# }

# output "cluster_endpoint" {
#   value = aws_eks_cluster.dev.endpoint
# }

# output "cluster_security_group_id" {
#   value = aws_eks_cluster.dev.vpc_config[0].cluster_security_group_id
# }

# output "oidc_issuer" {
#   value = aws_eks_cluster.dev.identity[0].oidc[0].issuer
# }