# locals {
  
#   environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
#   env = local.environment_vars.locals.env
#   environment = local.environment_vars.locals.environment
#   building_block = local.environment_vars.locals.building_block
#   random_string  = local.environment_vars.locals.random_string
# }


# terraform {
#   source = "../../modules//output-file/"
# }

# dependency "storage" {
#     config_path = "../storage"
#     mock_outputs = {
#       azurerm_storage_account_name = "dummy-account"
#       azurerm_storage_container_public = "dummy-container-public"
#       azurerm_storage_container_private = "dummy-container-private"
#       azurerm_storage_account_key = "dummy-key"
#     }
# }

# dependency "aks" {
#     config_path = "../aks"
# }

# inputs = {
#   env                                = local.environment_vars.locals.env
#   environment                        = local.environment
#   building_block                     = local.building_block
#   storage_account_name               = dependency.storage.outputs.azurerm_storage_account_name
#   storage_container_public           = dependency.storage.outputs.azurerm_storage_container_public
#   storage_container_private          = dependency.storage.outputs.azurerm_storage_container_private
#   storage_account_primary_access_key = dependency.storage.outputs.azurerm_storage_account_key
#   private_ingressgateway_ip          = dependency.aks.outputs.private_ingressgateway_ip
#   random_string                      = local.random_string
# }


locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  env              = local.environment_vars.locals.env
  environment      = local.environment_vars.locals.environment
  building_block   = local.environment_vars.locals.building_block
  random_string    = local.environment_vars.locals.random_string
}

terraform {
  source = "../../modules//output-file/"  # Adjust the source to your AWS output-file module path
}

dependency "storage" {
    config_path = "../storage"  # Adjust the config path to your AWS S3 module path
    mock_outputs = {
      aws_s3_bucket_name         = "dummy-bucket"
      aws_s3_bucket_arn          = "arn:aws:s3:::dummy-bucket"
      aws_s3_bucket_policy       = "dummy-policy"
      aws_s3_bucket_encryption   = "dummy-encryption"
      aws_s3_bucket_versioning   = "dummy-versioning"
    }
}

dependency "aks" {
    config_path = "../aks"  # Adjust the config path to your AWS EKS module path
    mock_outputs = {
      private_ingressgateway_ip = "dummy-private-ip"
    }
}

inputs = {
  env                                = local.env
  environment                        = local.environment
  building_block                     = local.building_block
  s3_bucket_name                     = dependency.s3.outputs.aws_s3_bucket_name
  s3_bucket_arn                      = dependency.s3.outputs.aws_s3_bucket_arn
  s3_bucket_policy                   = dependency.s3.outputs.aws_s3_bucket_policy
  s3_bucket_encryption               = dependency.s3.outputs.aws_s3_bucket_encryption
  s3_bucket_versioning               = dependency.s3.outputs.aws_s3_bucket_versioning
  private_ingressgateway_ip          = dependency.eks.outputs.private_ingressgateway_ip
  random_string                      = local.random_string
}
