# locals {
#   # This section will be enabled after final code is pushed and tagged
#   # source_base_url = "github.com/<org>/modules.git//app"
#   environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
#   environment = local.environment_vars.locals.environment
#   building_block = local.environment_vars.locals.building_block
#   random_string  = local.environment_vars.locals.random_string
# }

# # For local development
# terraform {
#   source = "../../modules//aks/"
# }

# dependency "network" {
#     config_path = "../network"
#     mock_outputs = {
#       resource_group_name = "dummy-rg"
#       aks_subnet_id = "dummy-subnet"
#     }
# }

# inputs = {
#   environment                = local.environment
#   building_block             = local.building_block
#   resource_group_name        = dependency.network.outputs.resource_group_name
#   vnet_subnet_id             = dependency.network.outputs.aks_subnet_id
# }

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment      = local.environment_vars.locals.environment
  building_block   = local.environment_vars.locals.building_block
  random_string    = local.environment_vars.locals.random_string
}

terraform {
  source = "../../modules//eks/"  # Adjust the source to your AWS EKS module path
}

dependency "network" {
  config_path = "../vpc"  # Adjust the config path to your AWS VPC module path
  mock_outputs = {
    vpc_id = "dummy-vpc"
    subnet_ids = ["dummy-subnet-1", "dummy-subnet-2"]  # Adjust to mock VPC subnet IDs
  }
}

inputs = {
  environment        = local.environment
  building_block     = local.building_block
  vpc_id             = dependency.network.outputs.vpc_id
  subnet_ids         = dependency.network.outputs.subnet_ids
}
