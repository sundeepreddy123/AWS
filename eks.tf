resource "aws_eks_cluster" "this" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_cluster.arn    ///creating role for eks cluster

  version = var.cluster_version

  vpc_config {

    subnet_ids = aws_subnet.private[*].ids   // EKS cluster will be created in private subnets

    endpoint_private_access = true // EKS cluster will be accessible only from private subnets

    endpoint_public_access = true // EKS cluster will not be accessible from public subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster // EKS cluster will be created only after the IAM role is attached to the policy 
  ]
}