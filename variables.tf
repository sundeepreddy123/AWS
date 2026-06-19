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
