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

# terraform {
#   backend "s3" {
#     bucket         = "template-tfstate-bucket"
#     key            = "terraform/terraform.tfstate"
#     region         = "us-east-1"
#     dynamodb_table = "template-tfstate-lock"
#   }
# }


terraform {
  source = "/home/ubuntu/sunbird-ed-installer/terraform/azure/modules/upload-files"
}

remote_state {
  backend = "s3"
  config = {
    bucket         = "template-tfstate-bucket"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "template-tfstate-lock"
  }
}
