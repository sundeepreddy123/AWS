provider "aws" {
  region = var.aws_region
}

terraform{
  backend "s3" {}
}

data "aws_eks_cluster_auth" "eks" {
  name = aws_eks_cluster.eks.name
}

provider "helm" {
  kubernetes = {
    host = data.aws_eks_cluster.eks.endpoint

    cluster_ca_certificate = base64decode(
      data.aws_eks_cluster.eks.certificate_authority[0].data
    )

    token = data.aws_eks_cluster_auth.eks.token
  }
}

provider "kubernetes" {
  host = data.aws_eks_cluster.eks.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.eks.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.eks.token
}

provider "kubectl" {

  host = data.aws_eks_cluster.eks.endpoint

  cluster_ca_certificate = base64decode(
    data.aws_eks_cluster.eks.certificate_authority[0].data
  )

  token = data.aws_eks_cluster_auth.eks.token

  load_config_file = false
}
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