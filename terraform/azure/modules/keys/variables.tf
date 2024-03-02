variable "environment" {
    type        = string
    description = "environment name. All resources will be prefixed with this value."
}

variable "building_block" {
    type        = string
    description = "Building block name. All resources will be prefixed with this value."
}

variable "bucket_name" {
    type        = string
    description = "Bucket name for S3 storage."
}

variable "public_bucket_name" {
    type        = string
    description = "Public bucket name with blob access."
}

variable "rsa_keys_count" {
    type        = number
    description = "Number of RSA keys to generate"
    default     = 2
}

variable "random_string" {
    type        = string
    description = "This string will be used to encrypt / mask various values. Use a strong random string in order to secure the applications. The string should be between 12 and 24 characters in length. If you forget the string, the application will stop working and the string cannot be retrieved."
    validation {
      condition     = length(var.random_string) >= 12 || length(var.random_string) <= 24
      error_message = "The string must have a length ranging from 12 to 24 characters."
  }
}

# provider "aws" {
#     region = var.base_location
# }

provider "aws" {
    region = "us-east-1" 
}


variable "base_location" {
  type        = string
  description = "Location of Terraform execution folder."
  #default = "us-east-1"
}


resource "aws_s3_bucket" "storage_bucket" {
    bucket = "${var.building_block}-${var.environment}-${var.bucket_name}"

    tags = {
        Environment   = var.environment
        BuildingBlock = var.building_block
    }
}

resource "aws_s3_bucket" "public_storage_bucket" {
    bucket = "${var.building_block}-${var.environment}-${var.public_bucket_name}"

    tags = {
        Environment   = var.environment
        BuildingBlock = var.building_block
    }
}

resource "aws_s3_object" "private_objects" {
    bucket = aws_s3_bucket.storage_bucket.id
    key    = "private/"

    server_side_encryption = "AES256"
}

resource "aws_s3_object" "public_objects" {
    bucket = aws_s3_bucket.public_storage_bucket.id
    key    = "public/"

    acl    = "public-read"
}

variable "storage_bucket_name" {
    type        = string
    description = "Name of the S3 bucket where the file will be uploaded."
}
