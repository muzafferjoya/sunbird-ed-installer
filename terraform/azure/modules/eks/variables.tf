variable "environment" {
  type        = string
  description = "Environment name. All resources will be prefixed with this value."
}

variable "building_block" {
  type        = string
  description = "Building block name. All resources will be prefixed with this value."
}

variable "region" {
  type        = string
  description = "AWS region to create the resources."
  default     = "us-east-1" 
}

variable "additional_tags" {
  type        = map(string)
  description = "Additional tags for the resources. These tags will be applied to all the resources."
  default     = {}
}

variable "node_instance_type" {
  type        = string
  description = "Instance type for the EC2 instances."
  default     = "t3a.medium"  
}

variable "node_count" {
  type        = number
  description = "Number of EC2 instances to launch."
  default     = 1
}

variable "service_cidr" {
  type        = string
  description = "Kubernetes service CIDR range."
  default     = "10.100.0.0/16"
}

variable "dns_service_ip" {
  type        = string
  description = "Kubernetes DNS service IP."
  default     = "10.100.10.100"
}

variable "private_ingressgateway_ip" {
  type        = string
  description = "Nginx private ingress IP."
  default     = "10.0.0.10"
}

variable "subnet_ids" {
  type        = list(string)
  description = "List of subnet IDs."
}

variable "small_nodepool_name" {
  type        = string
  description = "Name of the small node pool."
}

variable "small_node_count" {
  type        = number
  description = "Number of nodes in the small node pool."
}

variable "max_small_nodepool_nodes" {
  type        = number
  description = "Maximum number of nodes in the small node pool."
}

variable "ec2_ssh_key" {
  type        = string
  description = "Name of the EC2 SSH key pair."
}

variable "eks_cluster_is_public" {
  type        = bool
  description = "Specifies whether the EKS cluster is in public subnets or not."
  default     = false
}

variable "nat_gateway_id" {
  type        = string
  description = "ID of the NAT Gateway for private subnets."
  default     = "nat-0e636b6ac6d77b947"
}

variable "internet_gateway_id" {
  type        = string
  description = "ID of the Internet Gateway for public subnets."
  default     = "igw-0407ed598ca8effe3"
}
