resource "aws_eks_fargate_profile" "default" {

  cluster_name = aws_eks_cluster.this.name

  fargate_profile_name = "kube-system"

  pod_execution_role_arn = aws_iam_role.fargate.arn

  subnet_ids = data.aws_subnets.private.ids

  selector {
    namespace = "kube-system"
  }

  depends_on = [
    aws_iam_role_policy_attachment.fargate
  ]
}