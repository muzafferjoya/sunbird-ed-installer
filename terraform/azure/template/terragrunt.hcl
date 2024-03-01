# generate "backend" {
#   path      = "backend.tf"
#   if_exists = "overwrite_terragrunt"
#   contents = <<EOF
# terraform {
#   backend "azurerm" {
#     resource_group_name  = "${get_env("AZURE_TERRAFORM_BACKEND_RG")}"
#     storage_account_name = "${get_env("AZURE_TERRAFORM_BACKEND_STORAGE_ACCOUNT")}"
#     container_name       = "${get_env("AZURE_TERRAFORM_BACKEND_CONTAINER")}"
#     key                  = "${path_relative_to_include()}/terraform.tfstate"
#   }
# }
# EOF
# }

terraform {
  backend "s3" {
    bucket         = "dev-tfstate-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform_locks"
  }
}
