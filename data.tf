# data "aws_vpc" "main" {
#   id = aws_vpc.main.id
# }

# data "aws_subnets" "private" {

#   filter {
#     name   = "vpc-id"
#     values = [aws_vpc.main.id]
#   }

#   tags = {
#     Tier = "Private"

#   }
# }

data "aws_eks_cluster" "eks" {
  name = aws_eks_cluster.eks.name       /// We need to read information such as: OIDC Issuer URL, Cluster CA, Endpoint. Terraform asks AWS: "Give me information about my EKS cluster."
}

# data "aws_eks_cluster_auth" "eks" {
#   name = aws_eks_cluster.eks.name
# }

# data "aws_iam_policy_document" "cluster_autoscaler_assume" {

#   statement {

#     effect = "Allow"

#     principals {

#       type = "Service"

#       identifiers = [
#         "pods.eks.amazonaws.com"
#       ]
#     }

#     actions = [

#       "sts:AssumeRole",

#       "sts:TagSession"

#     ]
#   }
# }

data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer /// AWS IAM needs the SHA1 fingerprint of the OIDC certificate so it can trust tokens issued by the cluster
}

# resource "aws_iam_openid_connect_provider" "eks" {

#   client_id_list = [
#     "sts.amazonaws.com"
#   ]

#   thumbprint_list = [
#     data.tls_certificate.eks.certificates[0].sha1_fingerprint
#   ]

#   url = aws_eks_cluster.eks.identity[0].oidc[0].issuer // This is the OIDC issuer URL for the EKS cluster, which is used to configure the IAM OIDC provider for service account authentication. that makes the IAM OIDC provider trust the exact HTTPS certificate for your EKS OIDC issuer.connection 
#   }