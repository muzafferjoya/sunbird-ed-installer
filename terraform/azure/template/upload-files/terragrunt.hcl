# include "root" {
#   path = find_in_parent_folders("terragrunt.hcl")
# }

# include "environment" {
#   path = "${get_terragrunt_dir()}/../../_common/upload-files.hcl"

# }

# Include root configuration file
terraform {
  backend "s3" {
    bucket         = "dev-tfstate-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform_locks"
  }
}

# Include environment configuration file
include "environment" {
  path = "../_common/upload-files.tf"
}
