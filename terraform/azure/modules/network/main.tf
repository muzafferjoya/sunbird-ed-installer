# provider "aws" {
#   region = "us-east-1"
# }

# locals {
#     common_tags = {
#       Environment = var.environment
#       BuildingBlock = var.building_block
#     }
#     environment_name = "${var.building_block}-${var.environment}"
# }

# # resource "aws_vpc" "main" {
# #   cidr_block       = "10.0.0.0/16"
# #   enable_dns_support = true
# #   enable_dns_hostnames = true
# #   tags = merge(
# #       local.common_tags,
# #       var.additional_tags
# #       )
# # }

# # resource "aws_subnet" "subnets" {
# #   vpc_id            = aws_vpc.main.id
# #   cidr_block        = "10.0.0.0/20"
# #   availability_zone = "us-east-1a"
# #   tags = merge(
# #       local.common_tags,
# #       var.additional_tags
# #       )
# # }

# resource "aws_vpc" "main" {
#   cidr_block       = var.vpc_cidr_block
#   enable_dns_support = var.enable_dns_support
#   enable_dns_hostnames = var.enable_dns_hostnames
#   tags = merge(
#       local.common_tags,
#       var.additional_tags
#       )
# }

# resource "aws_subnet" "subnets" {
#   count             = length(var.subnet_cidr_blocks)
#   vpc_id            = aws_vpc.main.id
#   cidr_block        = var.subnet_cidr_blocks[count.index]
#   availability_zone = "us-east-1a"
#   tags = merge(
#       local.common_tags,
#       var.additional_tags
#       )
# }


# resource "aws_security_group" "example" {
#   vpc_id = aws_vpc.main.id

  
#   ingress {
#     from_port   = 80
#     to_port     = 80
#     protocol    = "tcp"
#     cidr_blocks = ["0.0.0.0/0"]
#   }

  
#   egress {
#     from_port   = 0
#     to_port     = 0
#     protocol    = "-1"
#     cidr_blocks = ["0.0.0.0/0"]
#   }
# }

## updated ##

provider "aws" {
  region = "us-east-1"
}

locals {
  common_tags      = {
    Environment   = var.environment
    BuildingBlock = var.building_block
  }
  environment_name = "${var.building_block}-${var.environment}"
}

resource "aws_vpc" "main" {
  cidr_block             = var.vpc_cidr_block
  enable_dns_support     = var.enable_dns_support
  enable_dns_hostnames   = var.enable_dns_hostnames
  tags                   = merge(local.common_tags, var.additional_tags)
}

resource "aws_subnet" "subnets" {
  count             = length(var.subnet_cidr_blocks)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_cidr_blocks[count.index]
  availability_zone = element(var.availability_zones, count.index) // Dynamically set availability zone
  tags              = merge(local.common_tags, var.additional_tags)
}

resource "aws_security_group" "example" {
  vpc_id = aws_vpc.main.id
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
