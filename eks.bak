resource "aws_eks_cluster" "this" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_cluster.arn

  version = var.cluster_version

  vpc_config {

    subnet_ids = data.aws_subnets.private.ids

    endpoint_private_access = true

    endpoint_public_access = true
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster
  ]
}