#!/bin/bash
set -euo pipefail

environment=$1
AWS_REGION="us-east-1"

# Define names for resources
BUCKET_NAME="${environment}-tfstate-bucket"
DYNAMODB_TABLE_NAME="${environment}-tfstate-lock"

# Create S3 bucket
#aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION --create-bucket-configuration LocationConstraint=$AWS_REGION
aws s3api create-bucket --bucket $BUCKET_NAME --region $AWS_REGION

# Enable versioning on S3 bucket
aws s3api put-bucket-versioning --bucket $BUCKET_NAME --versioning-configuration Status=Enabled

# Create DynamoDB table for locking
aws dynamodb create-table --table-name $DYNAMODB_TABLE_NAME --attribute-definitions AttributeName=LockID,AttributeType=S --key-schema AttributeName=LockID,KeyType=HASH --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 --region $AWS_REGION

# Output Terraform backend configuration
echo "terraform {
  backend \"s3\" {
    bucket         = \"$BUCKET_NAME\"
    key            = \"$environment/terraform.tfstate\"
    region         = \"$AWS_REGION\"
    dynamodb_table = \"$DYNAMODB_TABLE_NAME\"
  }
}" > backend.tf

echo -e "\nTerraform backend configuration has been created."
