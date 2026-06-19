// Create Instance Profile
resource "aws_iam_instance_profile" "karpenter" {
  name = "${var.cluster_name}-karpenter-profile"
  role = aws_iam_role.karpenter_node.name
}

// Create Fargate Profile for Karpenter
resource "aws_eks_fargate_profile" "karpenter" {

  cluster_name = aws_eks_cluster.this.name

  fargate_profile_name = "karpenter"

  pod_execution_role_arn = aws_iam_role.fargate.arn

  subnet_ids = data.aws_subnets.private.ids

  selector {
    namespace = "karpenter"
  }
}

data "aws_iam_policy_document" "karpenter_assume_role" {

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.eks.arn
      ]
    }

    condition {
      test = "StringEquals"

      variable = "${replace(
        aws_iam_openid_connect_provider.eks.url,
        "https://",
        ""
      )}:sub"

      values = [
        "system:serviceaccount:karpenter:karpenter"
      ]
    }
  }
}

resource "aws_iam_role" "karpenter_controller" {

  name = "${var.cluster_name}-karpenter-controller-role"

  assume_role_policy = data.aws_iam_policy_document.karpenter_assume_role.json
}

resource "aws_iam_policy" "karpenter_controller" {

  name = "${var.cluster_name}-karpenter-controller-policy"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeSubnets",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeImages",
          "ec2:CreateTags",
          "ec2:DeleteTags",

          "ssm:GetParameter",

          "eks:DescribeCluster",

          "pricing:GetProducts",

          "iam:PassRole"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "karpenter_controller" {

  role       = aws_iam_role.karpenter_controller.name

  policy_arn = aws_iam_policy.karpenter_controller.arn
}

resource "kubernetes_namespace_v1" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "kubernetes_service_account_v1" "karpenter" {

  metadata {
    name      = "karpenter"
    namespace = kubernetes_namespace_v1.karpenter.metadata[0].name

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.karpenter_controller.arn
    }
  }

  depends_on = [
    kubernetes_namespace_v1.karpenter
  ]
}

resource "helm_release" "karpenter" {

  name       = "karpenter"
  namespace  = "karpenter"

  repository = "oci://public.ecr.aws/karpenter"
  chart      = "karpenter"

  version = "1.3.3"

  values = [
    yamlencode({
      settings = {
        clusterName = aws_eks_cluster.this.name
      }
      serviceAccount = {
        create = false
        name   = "karpenter"
      }
    })
  ]

  depends_on = [
    kubernetes_service_account_v1.karpenter
  ]
}