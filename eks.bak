resource "aws_eks_cluster" "eks" {

  name = var.eks_cluster_name

  role_arn = aws_iam_role.eks.arn    ///creating role for eks cluster

  version = var.eks_version

  vpc_config {

    subnet_ids = data.aws_subnets.private.ids   // EKS cluster will be created in private subnets

    endpoint_private_access = true // EKS cluster will be accessible only from private subnets

    endpoint_public_access = true // EKS cluster will not be accessible from public subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks // EKS cluster will be created only after the IAM role is attached to the policy 
  ]
}


# resource "aws_eks_node_group" "general" {


#   cluster_name = aws_eks_cluster.eks.name


#   node_group_name = "general"


#   node_role_arn = aws_iam_role.node.arn


#   subnet_ids = data.aws_subnets.private.ids

#   capacity_type = "ON_DEMAND"


#   scaling_config {

#     desired_size = 3

#     max_size = 10

#     min_size = 1

#   }


#   instance_types = [ var.ec2_instance_type ]

# }

# resource "aws_eks_addon" "pod_identity" {
#   cluster_name = aws_eks_cluster.eks.name
#   addon_name   = "eks-pod-identity-agent"
# }

# resource "helm_release" "cluster_autoscaler" {

#   name = "cluster-autoscaler"

#   repository = "https://kubernetes.github.io/autoscaler"

#   chart = "cluster-autoscaler"

#   namespace = "kube-system"

#   version = "9.46.6"

#   set = [{

#     name = "autoDiscovery.clusterName"

#     value = aws_eks_cluster.eks.name
#   },
#   {

#     name = "awsRegion"

#     value = var.aws_region
#   },

#   {

#     name = "rbac.serviceAccount.create"

#     value = "false"
#   },

#   {

#     name = "rbac.serviceAccount.name"

#     value = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name
#   }]

#   depends_on = [

#     helm_release.metrics_server,

#     aws_eks_pod_identity_association.cluster_autoscaler

#   ]
# }