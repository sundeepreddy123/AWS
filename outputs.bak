output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnets" {
  value = aws_subnet.public[*].id
}

output "private_subnets" {
  value = aws_subnet.private[*].id
}

# output "eks_cluster_name" {
#   value = aws_eks_cluster.eks.name
# }

# output "cluster_endpoint" {
#   value = aws_eks_cluster.eks.endpoint
# }

# output "cluster_security_group_id" {
#   value = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
# }

# output "oidc_issuer" {
#   value = aws_eks_cluster.eks.identity[0].oidc[0].issuer
# }