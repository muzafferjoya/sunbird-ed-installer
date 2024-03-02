provider "null" {}

locals {
  global_values_keys_file          = "${var.base_location}/../global-keys-values.yaml"
  jwt_script_location             = "${var.base_location}/../../../../scripts/jwt-keys.py"
  rsa_script_location             = "${var.base_location}/../../../../scripts/rsa-keys.py"
  global_values_jwt_file_location = "${var.base_location}/../../../../scripts/global-values-jwt-tokens.yaml"
  global_values_rsa_file_location = "${var.base_location}/../../../../scripts/global-values-rsa-keys.yaml"
}

resource "null_resource" "generate_jwt_keys" {
  triggers = {
    command = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "python3 ${local.jwt_script_location} ${var.random_string} && cp ${local.global_values_jwt_file_location} ${var.base_location}/../global-values-jwt-tokens.yaml"
  }
}

resource "null_resource" "generate_rsa_keys" {
  provisioner "local-exec" {
    command = "python3 ${local.rsa_script_location} ${var.rsa_keys_count} && cp ${local.global_values_rsa_file_location} ${var.base_location}/../global-values-rsa-keys.yaml"
  }
}

resource "null_resource" "upload_global_jwt_values_yaml" {
  triggers = {
    command = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws s3 cp ${var.base_location}/../global-values-jwt-tokens.yaml s3://${var.storage_bucket_name}/${var.environment}-global-values-jwt-tokens.yaml"
  }

  depends_on = [null_resource.generate_jwt_keys]
}

resource "null_resource" "upload_global_rsa_values_yaml" {
  triggers = {
    command = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "aws s3 cp ${var.base_location}/../global-values-rsa-keys.yaml s3://${var.storage_bucket_name}/${var.environment}-global-values-rsa-keys.yaml"
  }

  depends_on = [null_resource.generate_rsa_keys]
}
