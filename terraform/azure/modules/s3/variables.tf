variable "environment" {
    type        = string
    description = "environment name. All resources will be prefixed with this value."
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

variable "s3_storage_class" {
    type        = string
    description = "S3 storage class - STANDARD / STANDARD_IA / ONEZONE_IA / INTELLIGENT_TIERING etc."
    default     = "STANDARD"
}

variable "s3_replication" {
    type        = string
    description = "S3 replication configuration - none / S3 / CRR etc."
    default     = "none"
}

# variable "resource_group_name" {
#   type        = string
#   description = "Resource group name to create the S3 bucket."
# }

resource "aws_s3_bucket" "example_bucket" {
  bucket = "${var.environment}-${var.building_block}-bucket"

  tags = merge(
    var.additional_tags,
    {
      Environment   = var.environment
      BuildingBlock = var.building_block
    }
  )

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_acl" "example_bucket_acl" {
  bucket = aws_s3_bucket.example_bucket.id

  acl = "private"
}
