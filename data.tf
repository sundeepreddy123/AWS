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

# data "tls_certificate" "eks" {
#   url = aws_eks_cluster.dev.identity[0].oidc[0].issuer
# }

# resource "aws_iam_openid_connect_provider" "eks" {

#   client_id_list = [
#     "sts.amazonaws.com"
#   ]

#   thumbprint_list = [
#     data.tls_certificate.eks.certificates[0].sha1_fingerprint
#   ]

#   url = aws_eks_cluster.dev.identity[0].oidc[0].issuer // This is the OIDC issuer URL for the EKS cluster, which is used to configure the IAM OIDC provider for service account authentication. that makes the IAM OIDC provider trust the exact HTTPS certificate for your EKS OIDC issuer.connection 
#   }