// eks_cluster-role
resource "aws_iam_role" "eks_cluster" {

  name = "${var.cluster_name}-cluster-role"

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
resource "aws_iam_role_policy_attachment" "eks_cluster" {

  role = aws_iam_role.eks_cluster.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


// fargate-role

resource "aws_iam_role" "fargate" {

  name = "${var.cluster_name}-fargate-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [{
      Effect = "Allow"

      Principal = {
        Service = "eks-fargate-pods.amazonaws.com"
      }

      Action = "sts:AssumeRole"
    }]
  })
}

// policy attachment for fargate role
resource "aws_iam_role_policy_attachment" "fargate" {

  role = aws_iam_role.fargate.name

  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSFargatePodExecutionRolePolicy"
}