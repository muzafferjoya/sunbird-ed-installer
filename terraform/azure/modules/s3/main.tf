provider "aws" {
  region = var.region
}

locals {
  bucket_name = "${var.building_block}-${var.environment}-bucket"
}


resource "aws_s3_bucket" "storage_bucket" {
  bucket = "${var.environment}-${var.building_block}-bucket"

  tags = {
    Environment   = var.environment
    BuildingBlock = var.building_block
  }

  lifecycle {
    prevent_destroy = true
  }
}


# resource "aws_s3_bucket_acl" "storage_bucket_acl" {
#   bucket = aws_s3_bucket.storage_bucket.id

#   acl = "private"
# }

resource "aws_s3_bucket_cors_configuration" "storage_bucket_cors_configuration" {
  bucket = aws_s3_bucket.storage_bucket.id

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET", "HEAD", "PUT"]
    allowed_origins = ["*"]
    expose_headers  = ["Access-Control-Allow-Origin", "Access-Control-Allow-Methods"]
    max_age_seconds = 200
  }
}

resource "aws_s3_bucket_versioning" "storage_bucket_versioning" {
  bucket = aws_s3_bucket.storage_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_object" "reports_container_private" {
  bucket = aws_s3_bucket.storage_bucket.id
  key    = "reports/"
}

resource "aws_s3_object" "telemetry_container_private" {
  bucket = aws_s3_bucket.storage_bucket.id
  key    = "telemetry-data-store/"
}

resource "aws_s3_object" "backups_container_private" {
  bucket = aws_s3_bucket.storage_bucket.id
  key    = "backups/"
}

resource "aws_s3_object" "flink_state_container_private" {
  bucket = aws_s3_bucket.storage_bucket.id
  key    = "flink-state-backend/"
}

resource "aws_s3_object" "dial_state_container_public" {
  bucket = aws_s3_bucket.storage_bucket.id
  key    = "dial/"
}
