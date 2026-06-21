resource "helm_release" "alb" {


name="aws-load-balancer-controller"


repository="https://aws.github.io/eks-charts"


chart="aws-load-balancer-controller"


namespace="kube-system"


values = [<<EOF
clusterName: ${aws_eks_cluster.dev.name}
vpcId: ${aws_vpc.main.id}
serviceAccount:
  create: false
  name: aws-load-balancer-controller
EOF
]

depends_on=[
    kubernetes_service_account_v1.alb_controller
]

}