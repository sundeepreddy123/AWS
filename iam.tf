// eks_cluster-role
resource "aws_iam_role" "eks" {

  name = "${var.eks_cluster_name}-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}
// policy attachment for eks_cluster role
resource "aws_iam_role_policy_attachment" "eks" {

  role = aws_iam_role.eks.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

/// Node group role for eks cluster

resource "aws_iam_role" "node" {

  name = "${var.eks_cluster_name}-node-role"

  assume_role_policy = jsonencode({

    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ec2.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]

  })
}

resource "aws_iam_role_policy_attachment" "worker" {

  role = aws_iam_role.node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"

}


resource "aws_iam_role_policy_attachment" "cni" {

  role = aws_iam_role.node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

}

// policy
resource "aws_iam_role_policy_attachment" "ecr" {

  role = aws_iam_role.node.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"

}

# // cluster role for eks_cluster_autoscaler
# resource "aws_iam_policy" "cluster_autoscaler" {

#   name = "${var.eks_cluster_name}-cluster-autoscaler"

#   policy = jsonencode({

#     Version = "2012-10-17"

#     Statement = [

#       {
#         Effect = "Allow"

#         Action = [
#           "autoscaling:DescribeAutoScalingGroups",
#           "autoscaling:DescribeAutoScalingInstances",
#           "autoscaling:DescribeLaunchConfigurations",
#           "autoscaling:DescribeScalingActivities",
#           "autoscaling:DescribeTags",
#           "autoscaling:SetDesiredCapacity",
#           "autoscaling:TerminateInstanceInAutoScalingGroup",
#           "ec2:DescribeLaunchTemplateVersions"
#         ]

#         Resource = "*"
#       }
#     ]
#   })
# }


# resource "aws_iam_role" "cluster_autoscaler" {

#   name = "${var.eks_cluster_name}-cluster-autoscaler"

#   assume_role_policy = data.aws_iam_policy_document.cluster_autoscaler_assume.json
# }

# /// attched policy
# resource "aws_iam_role_policy_attachment" "cluster_autoscaler" {

#   role = aws_iam_role.cluster_autoscaler.name

#   policy_arn = aws_iam_policy.cluster_autoscaler.arn
# }
# //// This is where Pod Identity connects the Kubernetes ServiceAccount to the IAM role.
# resource "aws_eks_pod_identity_association" "cluster_autoscaler" {

#   cluster_name = aws_eks_cluster.eks.name

#   namespace = "kube-system"

#   service_account = kubernetes_service_account_v1.cluster_autoscaler.metadata[0].name

#   role_arn = aws_iam_role.cluster_autoscaler.arn
# }

# // IAM Role for IRSA (Trust relationship)
# resource "aws_iam_role" "aws_load_balancer_controller" {

#   name = "AWSLoadBalancerControllerRole"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [{
#       Effect = "Allow"

#       Principal = {
#         Federated = aws_iam_openid_connect_provider.eks.arn
#       }

#       Action = "sts:AssumeRoleWithWebIdentity"

#       Condition = {
#         StringEquals = {
#           "${replace(
#             aws_iam_openid_connect_provider.eks.url,
#             "https://",
#             ""
#           )}:sub" ="system:serviceaccount:kube-system:aws-load-balancer-controller"
#         }
#       }
#     }]
#   })
# }

# data "aws_iam_policy_document" "aws_lbc" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["pods.eks.amazonaws.com"]
#     }

#     actions = [
#       "sts:AssumeRole",
#       "sts:TagSession"
#     ]
#   }
# }

// IAM Policy for AWS Load Balancer Controller permissions
# resource "aws_iam_policy" "lb_controller_policy" {

#   name = "AWSLoadBalancerControllerIAMPolicy"

#   policy = file("iam_policy.json")
# }
# // Attach Policy to Rolewhere iAM role for load 
# resource "aws_iam_role_policy_attachment" "lb_controller" {

#   role = aws_iam_role.aws_load_balancer_controller.name

#   policy_arn = aws_iam_policy.lb_controller_policy.arn
# }

// fargate-role

# resource "aws_iam_role" "fargate" {

#   name = "${var.cluster_name}-fargate-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [{
#       Effect = "Allow"

#       Principal = {
#         Service = "eks-fargate-pods.amazonaws.com"
#       }

#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# // policy attachment for fargate role
# resource "aws_iam_role_policy_attachment" "fargate" {

#   role = aws_iam_role.fargate.name

#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
# }

# // Create Node IAM Role for karpenter

# resource "aws_iam_role" "karpenter_node" {
#   name = "${var.cluster_name}-karpenter-node-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [{
#       Effect = "Allow"

#       Principal = {
#         Service = "ec2.amazonaws.com"
#       }

#       Action = "sts:AssumeRole"
#     }]
#   })
# }

# // Attach policies to karpenter node role
# resource "aws_iam_role_policy_attachment" "karpenter_node" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_cni" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_registry" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
# }

# resource "aws_iam_role_policy_attachment" "karpenter_spot" {
#   role       = aws_iam_role.karpenter_node.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
# }