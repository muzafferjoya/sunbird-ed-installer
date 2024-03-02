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
