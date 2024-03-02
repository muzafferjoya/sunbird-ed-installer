# variable "environment" {
#     type        = string
#     description = "Environment name. All resources will be prefixed with this value."
# }

# variable "building_block" {
#     type        = string
#     description = "Building block name. All resources will be prefixed with this value."
# }

# variable "region" {
#     type        = string
#     description = "AWS region to create the resources."
#     default     = "us-east-1"
# }

# variable "additional_tags" {
#     type        = map(string)
#     description = "Additional tags for the resources. These tags will be applied to all the resources."
#     default     = {}
# }

# variable "vpc_cidr_block" {
#     type        = string
#     description = "CIDR block for the VPC."
#     default     = "10.0.0.0/16"
# }

# variable "subnet_cidr_blocks" {
#     type        = list(string)
#     description = "CIDR blocks for the subnets within the VPC."
#     default     = ["10.0.1.0/24", "10.0.2.0/24"] 
# }

# variable "enable_dns_support" {
#     type        = bool
#     description = "Should be true to enable DNS support in the VPC."
#     default     = true
# }

# variable "enable_dns_hostnames" {
#     type        = bool
#     description = "Should be true to enable DNS hostnames in the VPC."
#     default     = true
# }

#### updated

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

variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC."
  default     = "10.0.0.0/16"
}

variable "subnet_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks for the subnets within the VPC."
  default     = ["10.0.1.0/24", "10.0.2.0/24"] 
}

variable "enable_dns_support" {
  type        = bool
  description = "Should be true to enable DNS support in the VPC."
  default     = true
}

variable "enable_dns_hostnames" {
  type        = bool
  description = "Should be true to enable DNS hostnames in the VPC."
  default     = true
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones where subnets will be created."
  default     = ["us-east-1a", "us-east-1b"]
}
