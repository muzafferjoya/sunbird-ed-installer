provider "aws" {
  region = var.region
}

locals {
  common_tags = {
    environment   = var.environment
    BuildingBlock = var.building_block
  }
  environment_name = "${var.building_block}-${var.environment}"
}

resource "aws_iam_user" "eks_user" {
  name = local.environment_name
}

resource "aws_iam_access_key" "eks_access_key" {
  user = aws_iam_user.eks_user.name
}

resource "aws_eks_cluster" "eks" {
  name     = local.environment_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }

  tags = merge(local.common_tags, var.additional_tags)
}

resource "aws_eks_node_group" "small_nodepool" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = var.small_nodepool_name
  node_role_arn   = aws_iam_role.node_role.arn

  scaling_config {
    desired_size = var.small_node_count
    max_size     = var.max_small_nodepool_nodes
    min_size     = 1
  }

  remote_access {
    ec2_ssh_key = var.ec2_ssh_key
  }

  subnet_ids = var.subnet_ids

  tags = merge(local.common_tags, var.additional_tags)
}

resource "aws_iam_role" "eks_role" {
  name               = "eks-service-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_policy_attachment" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_iam_role" "node_role" {
  name               = "eks-node-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "node_policy_attachment" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "node_cni_policy_attachment" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "node_ec2_policy_attachment" {
  role       = aws_iam_role.node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

data "aws_security_groups" "node_security_group" {
  filter {
    name   = "tag:Name"
    values = ["your-node-security-group-name"]
  }
}

data "aws_subnet" "eks_subnets" {
  for_each = toset(var.subnet_ids)

  id = each.value
}


resource "null_resource" "security_group_checks" {
  depends_on = [aws_eks_cluster.eks]

  provisioner "local-exec" {
    command = <<-EOT
      # Check if node security group allows necessary traffic
      # For example, you can use tools like nmap or aws cli commands here to check the rules.
      # Example: aws ec2 describe-security-groups --group-ids ${data.aws_security_groups.node_security_group.ids}

      # Check connectivity to Internet Gateway if EKS is in public subnet
      # For example, you can use ping or traceroute commands here.
      # Example: ping -c 4 www.google.com

      # Check NAT Gateway connectivity if EKS is in private subnet
      # For example, you can use curl or traceroute commands here.
      # Example: curl www.google.com
    EOT
  }
}

# resource "aws_vpc_endpoint" "eks_internet_access" {
#   count       = length(data.aws_subnet.eks_subnets.ids) > 0 ? 1 : 0
#   vpc_id      = aws_eks_cluster.eks.vpc_config[0].vpc_id
#   service_name = "com.amazonaws.${var.region}.s3"
# }

# resource "aws_vpc_endpoint" "eks_nat_gateway_access" {
#   count       = length(data.aws_subnet.eks_subnets.ids) == 0 ? 1 : 0
#   vpc_id      = aws_eks_cluster.eks.vpc_config[0].vpc_id
#   service_name = "com.amazonaws.${var.region}.s3"
# }
resource "aws_vpc_endpoint" "eks_internet_access" {
  count       = var.eks_cluster_is_public ? length(data.aws_subnet.eks_subnets) > 0 ? 1 : 0 : 0
  vpc_id      = aws_eks_cluster.eks.vpc_config[0].vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint" "eks_nat_gateway_access" {
  count       = !var.eks_cluster_is_public ? length(data.aws_subnet.eks_subnets) > 0 ? 1 : 0 : 0
  vpc_id      = aws_eks_cluster.eks.vpc_config[0].vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}
