# locals {
 
#   environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
#   environment = local.environment_vars.locals.environment
#   building_block = local.environment_vars.locals.building_block
# }

# # For local development
# terraform {
#   source = "../../modules//storage/"
# }

# dependency "network" {
#     config_path = "../network"
#     mock_outputs = {
#       resource_group_name = "dummy-rg"
#     }
# }

# inputs = {
#   environment                 = local.environment
#   building_block      = local.building_block
#   resource_group_name = dependency.network.outputs.resource_group_name
# }

locals {
  environment_vars = read_terragrunt_config(find_in_parent_folders("environment.hcl"))
  environment      = local.environment_vars.locals.environment
  building_block   = local.environment_vars.locals.building_block
}

terraform {
  source = "../../modules//storage/"  # Adjust the source to your AWS S3 module path
}

dependency "network" {
    config_path = "../network"  # Adjust the config path to your AWS VPC module path
    mock_outputs = {
      vpc_id = "dummy-vpc"
    }
}

inputs = {
  environment        = local.environment
  building_block     = local.building_block
  vpc_id             = dependency.vpc.outputs.vpc_id
}
