# # For local development
# terraform {
#   source = "../../modules//upload-files/"
# }

# dependency "storage" {
#     config_path = "../storage"
#     mock_outputs = {
#       azurerm_storage_account_name = "dummy-account"
#       azurerm_storage_container_public = "dummy-container-public"
#       azurerm_storage_account_key = "dummy-key"
#     }
# }

# inputs = {
#   storage_account_name               = dependency.storage.outputs.azurerm_storage_account_name
#   storage_container_public           = dependency.storage.outputs.azurerm_storage_container_public
#   storage_account_primary_access_key = dependency.storage.outputs.azurerm_storage_account_key
# }

terraform {
  source = "../../modules//upload-files/"  # Adjust the source to your AWS S3 module path
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

inputs = {
  s3_bucket_name                     = dependency.s3.outputs.aws_s3_bucket_name
  s3_bucket_arn                      = dependency.s3.outputs.aws_s3_bucket_arn
  s3_bucket_policy                   = dependency.s3.outputs.aws_s3_bucket_policy
  s3_bucket_encryption               = dependency.s3.outputs.aws_s3_bucket_encryption
  s3_bucket_versioning               = dependency.s3.outputs.aws_s3_bucket_versioning
}
