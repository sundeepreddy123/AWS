provider "aws" {
  region = var.aws_region
}

terraform{
  backend "s3" {}
}


# provider "helm" {
#   kubernetes = {
#     host = aws_eks_cluster.this.endpoint

#     cluster_ca_certificate = base64decode(
#       data.aws_eks_cluster.this.certificate_authority[0].data
#     )

#     token = aws_eks_cluster_auth.this.token
#   }
# }

# provider "kubernetes" {
#   host = aws_eks_cluster.this.endpoint

#   cluster_ca_certificate = base64decode(
#     aws_eks_cluster.this.certificate_authority[0].data
#   )

#   token = aws_eks_cluster_auth.this.token
# }

# provider "kubectl" {
#   host                   = aws_eks_cluster.this.endpoint

#   cluster_ca_certificate = base64decode(
#     aws_eks_cluster.this.certificate_authority[0].data
#   )

#   load_config_file = false

#   exec {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"

#     args = [
#       "eks",
#       "get-token",
#       "--cluster-name",
#       aws_eks_cluster.this.name
#     ]
#   }
# }
# provider "helm" {
#   kubernetes = {
#     host                   = module.eks.cluster_endpoint
#     cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#     exec = {
#       api_version = "client.authentication.k8s.io/v1beta1"
#       command     = "aws"
#       # This requires the awscli to be installed locally where Terraform is executed
#       args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#     }
#   }
# }

# provider "kubectl" {
#   host                   = module.eks.cluster_endpoint
#   cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)

#   exec = {
#     api_version = "client.authentication.k8s.io/v1beta1"
#     command     = "aws"
#     # This requires the awscli to be installed locally where Terraform is executed
#     args = ["eks", "get-token", "--cluster-name", module.eks.cluster_name]
#   }
# }