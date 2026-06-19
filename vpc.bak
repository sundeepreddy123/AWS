module "vpc" {
    source = "terraform-aws-modules/vpc/aws"

    name = "vpc-dev"
    cidr = "10.0.0.0/16"

    azs             = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
    private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
    public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

    enable_nat_gateway = true 
    enable_vpn_gateway = false
    single_nat_gateway = true // true if you want to create only one NAT gateway in the first public subnet or else it will create one NAT gateway in each private subnet
    map_public_ip_on_launch = true // true if you want to assign public IPs to instances in public subnets

    tags = {
        Terraform   = "true"
        Environment = "dev"
    }

    public_subnet_tags = {
        "kubernetes.io/role/elb" = 1 // identifies public subnets for internet-facing ALBs/NLBs,
    }

    private_subnet_tags = {
        "kubernetes.io/role/internal-elb" = 1 // identifies private subnets for internal load balancers. Without these tags, Kubernetes may not be able to provision AWS load balancers automatically.
    }
}