resource "helm_release" "alb" {


name="aws-load-balancer-controller"


repository="https://aws.github.io/eks-charts"


chart="aws-load-balancer-controller"


namespace="kube-system"


values = [<<EOF
clusterName: ${aws_eks_cluster.this.name}
serviceAccount:
  create: false
  name: aws-load-balancer-controller
EOF
]


depends_on=[
kubernetes_service_account.alb_controller.metadata[0].name
]

}