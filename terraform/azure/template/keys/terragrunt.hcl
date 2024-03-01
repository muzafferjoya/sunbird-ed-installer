include "root" {
  path = find_in_parent_folders("terragrunt.hcl")
}

include "environment" {
  path = "${get_terragrunt_dir()}/../../_common/keys.hcl"

}

inputs = {
  base_location = get_terragrunt_dir()
}