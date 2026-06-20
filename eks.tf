resource "aws_eks_cluster" "dev" {

  name = var.cluster_name

  role_arn = aws_iam_role.eks_cluster.arn    ///creating role for eks cluster

  version = var.cluster_version

  vpc_config {

    subnet_ids = data.aws_subnets.private.ids   // EKS cluster will be created in private subnets

    endpoint_private_access = true // EKS cluster will be accessible only from private subnets

    endpoint_public_access = true // EKS cluster will not be accessible from public subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster // EKS cluster will be created only after the IAM role is attached to the policy 
  ]
}


resource "aws_eks_node_group" "general" {


  cluster_name = aws_eks_cluster.dev.name


  node_group_name = "general"


  node_role_arn = aws_iam_role.node.arn


  subnet_ids = data.aws_subnets.private.ids


  scaling_config {

    desired_size = 3

    max_size = 5

    min_size = 1

  }


  instance_types = [
    "t3.micro"
  ]

}