resource "aws_eks_cluster" "eks" {

  name = var.eks_cluster_name

  role_arn = aws_iam_role.eks.arn    ///creating role for eks cluster

  version = var.eks_version

  vpc_config {

    subnet_ids = aws_subnet.private[*].id   // EKS cluster will be created in private subnets

    endpoint_private_access = true // EKS cluster will be accessible only from private subnets

    endpoint_public_access = true // EKS cluster will not be accessible from public subnets
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks // EKS cluster will be created only after the IAM role is attached to the policy 
  ]
}


resource "aws_eks_node_group" "node_group" {


  cluster_name = aws_eks_cluster.eks.name


  node_group_name = "eks-node-groups"


  node_role_arn = aws_iam_role.node.arn


  subnet_ids = aws_subnet.private[*].id

  capacity_type = "ON_DEMAND"


  scaling_config {

    desired_size = 9

    max_size = 10

    min_size = 3

  }


  instance_types = [ var.ec2_instance_type ]

}


# resource "aws_eks_fargate_profile" "fargate" {

#   cluster_name = aws_eks_cluster.eks.name

#   fargate_profile_name = "kube-system"

#   pod_execution_role_arn = aws_iam_role.fargate.arn

#   subnet_ids = aws_subnet.private[*].id

#   selector {
#     namespace = "kube-system"
#   }

#   depends_on = [
#     aws_iam_role_policy_attachment.fargate
#   ]
# }



# // Create Instance Profile
# resource "aws_iam_instance_profile" "karpenter" {
#   name = "${var.eks_cluster_name}-karpenter-profile"
#   role = aws_iam_role.karpenter_node.name
# }

# // Create Fargate Profile for Karpenter
# resource "aws_eks_fargate_profile" "karpenter" {

#   cluster_name = aws_eks_cluster.eks.name

#   fargate_profile_name = "karpenter"

#   pod_execution_role_arn = aws_iam_role.fargate.arn

#   subnet_ids = aws_subnet.private[*].id

#   selector {
#     namespace = "karpenter"
#   }
# }

# data "aws_iam_policy_document" "karpenter_assume_role" {

#   statement {
#     effect = "Allow"

#     actions = [
#       "sts:AssumeRoleWithWebIdentity"
#     ]

#     principals {
#       type = "Federated"

#       identifiers = [
#         aws_iam_openid_connect_provider.eks.arn
#       ]
#     }

#     condition {
#       test = "StringEquals"

#       variable = "${replace(
#         aws_iam_openid_connect_provider.eks.url,
#         "https://",
#         ""
#       )}:sub"

#       values = [
#         "system:serviceaccount:karpenter:karpenter"
#       ]
#     }
#   }
# }

# resource "aws_iam_role" "karpenter_controller" {

#   name = "${var.eks_cluster_name}-karpenter-controller-role"

#   assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
# }

# resource "aws_iam_policy" "karpenter_controller" {

#   name = "${var.eks_cluster_name}-karpenter-controller-policy"

#   policy = jsonencode({
#     Version = "2012-10-17"

#     Statement = [
#       {
#         Effect = "Allow"

#         Action = [
#           "ec2:RunInstances",
#           "ec2:CreateFleet",
#           "ec2:TerminateInstances",
#           "ec2:DescribeInstances",
#           "ec2:DescribeInstanceTypes",
#           "ec2:DescribeSubnets",
#           "ec2:DescribeSecurityGroups",
#           "ec2:DescribeImages",
#           "ec2:CreateTags",
#           "ec2:DeleteTags",

#           "ssm:GetParameter",

#           "eks:DescribeCluster",

#           "pricing:GetProducts",

#           "iam:PassRole",
#           "iam:GetInstanceProfile",
#           "iam:CreateInstanceProfile",
#           "iam:AddRoleToInstanceProfile",
#           "iam:RemoveRoleFromInstanceProfile",
#           "iam:DeleteInstanceProfile",
#           "iam:TagInstanceProfile"
#         ]

#         Resource = "*"
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "karpenter_controller" {

#   role       = aws_iam_role.karpenter_controller.name

#   policy_arn = aws_iam_policy.karpenter_controller.arn
# }

# resource "kubernetes_namespace_v1" "karpenter" {
#   metadata {
#     name = "karpenter"
#   }
# }

# resource "kubernetes_service_account_v1" "karpenter" {

#   metadata {
#     name      = "karpenter"
#     namespace = kubernetes_namespace_v1.karpenter.metadata[0].name

#     annotations = {
#       "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
#     }
#   }

#   depends_on = [
#     kubernetes_namespace_v1.karpenter
#   ]
# }

# resource "helm_release" "karpenter" {

#   name       = "karpenter"
#   namespace  = "karpenter"

#   repository = "oci://public.ecr.aws/karpenter"
#   chart      = "karpenter"

#   version = "1.3.3"

#   values = [
#     yamlencode({
#       settings = {
#         clusterName = aws_eks_cluster.eks.name
#       }
#       serviceAccount = {
#         create = false
#         name   = "karpenter"
#       }
#     })
#   ]

#   depends_on = [
#     kubernetes_service_account_v1.karpenter
#   ]
# }

# resource "aws_ec2_tag" "private_subnet_discovery" {
#   for_each    = toset(aws_subnet.private[*].id)

#   resource_id = each.value
#   key         = "karpenter.sh/discovery"
#   value       = aws_eks_cluster.eks.name
# }

# resource "aws_ec2_tag" "cluster_sg_discovery" {
#   resource_id = aws_eks_cluster.eks.vpc_config[*].cluster_security_group_id

#   key   = "karpenter.sh/discovery"
#   value = aws_eks_cluster.eks.name
# }

# resource "kubectl_manifest" "ec2_nodeclass" {

#   depends_on = [
#     helm_release.karpenter
#   ]

#   yaml_body = <<YAML
# apiVersion: karpenter.k8s.aws/v1
# kind: EC2NodeClass
# metadata:
#   name: default
# spec:
#   amiFamily: AL2023

#   amiSelectorTerms:
#     - alias: al2023@latest

#   role: ${aws_iam_role.karpenter_node.name}

#   subnetSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${aws_eks_cluster.eks.name}

#   securityGroupSelectorTerms:
#   - tags:
#       karpenter.sh/discovery: ${aws_eks_cluster.eks.name}
# YAML
# }

# resource "kubectl_manifest" "nodepool" {

#   depends_on = [
#     kubectl_manifest.ec2_nodeclass
#   ]

#   yaml_body = <<YAML
# apiVersion: karpenter.sh/v1
# kind: NodePool
# metadata:
#   name: default
# spec:
#   template:
#     spec:
#     #   taints:
#     #   - key: workload
#     #     value: app
#     #     effect: NoSchedule

#       nodeClassRef:
#         group: karpenter.k8s.aws
#         kind: EC2NodeClass
#         name: default

#       requirements:

#       - key: kubernetes.io/arch
#         operator: In
#         values:
#         - amd64

#       - key: karpenter.sh/capacity-type
#         operator: In
#         values:
#         - on-demand

#     #   - key: node.kubernetes.io/instance-type
#     #     operator: In
#     #     values:
#     #     - t3.large
#     #     - m5.large

#   limits:
#     cpu: 100

#   disruption:
#     consolidationPolicy: WhenEmptyOrUnderutilized
#     consolidateAfter: 30s
# YAML
# }