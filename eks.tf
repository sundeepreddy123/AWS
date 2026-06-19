module "eks" {
  source = "terraform-aws-modules/eks/aws"
  
  name                   = var.cluster_name
  kubernetes_version     = var.cluster_version
  endpoint_public_access = true
  version = "~> 21.0"
  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
    enable_cluster_creator_admin_permissions = false
    #endpoint_public_access_cidrs = var.cluster_endpoint_public_access_cidrs


  addons = {
      eks-pod-identity-agent = {
        before_compute = true
      }
    coredns = {
      most_recent = true
      before_compute  = false
      # configuration_values = jsonencode({
      # computeType = "Fargate"
      #   # Ensure that we fully utilize the minimum amount of resources that are supplied by
      #   # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
      #   # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
      #   # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
      #   # compute configuration that most closely matches the sum of vCPU and memory requests in
      #   # order to ensure pods always have the resources that they need to run.
      #   resources = {
      #     limits = {
      #       cpu = "0.25"
      #       # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
      #       # request/limit to ensure we can fit within that task
      #       memory = "256M"
      #     }
      #     requests = {
      #       cpu = "0.25"
      #       # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
      #       # request/limit to ensure we can fit within that task
      #       memory = "256M"
      #     }
      #   }
      # })
    }
    kube-proxy = {
        most_recent = true
        before_compute = false
    }
    vpc-cni    = {
        most_recent = true
        before_compute = true
        configuration_values = jsonencode({
            env ={
           ENABLE_PREFIX_DELEGATION = "true"
           WARM_PREFIX_TARGET = "1"
            }
        })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.private_subnets
  #control_plane_subnet_ids = module.vpc.intra_subnets
   authentication_mode = "API"
  # Fargate profiles use the cluster primary security group so these are not utilized
  create_security_group = false
  create_node_security_group    = false

  fargate_profiles = {
    karpenter = {
      selectors = [
       { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }

   access_entries = {
     #One access entry with a policy associated
     Devs = {
       kubernetes_groups = []
       principal_arn     = var.iam_role_arn

       policy_associations = {
         cluster_admin = {
           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
           access_scope = {
             namespaces = []
             type       = "cluster"
            }
          }
        }
      }
    }

  tags =  {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster_name
  }
}