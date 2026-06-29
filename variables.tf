variable "aws_region" {
  description = "AWS region"
  type        = string
}

variable "env" {
  description = "Environment name (e.g. dev, stage, prod)"
  type        = string
}


variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "az_zones" {
  description = "List of availability zones to use"
  type        = list(string)
}

variable "ec2_ami_id" {
  description = "AMI ID for the EC2 instances"
  type        = string
  default     = "ami-0e38835daf6b8a2b9" # Amazon Linux 2 AMI (HVM), SSD Volume Type
}

variable "ec2_instance_type" {
  description = "EC2 instance type for the worker nodes"
  type        = string
  default     = "t3.micro"
}



variable "eks_cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "eks_version" {
  description = "EKS cluster version"
  type        = string
}

variable "email" {
    description = "email for sns"
    type = string  
}