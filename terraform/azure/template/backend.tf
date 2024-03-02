terraform {
  backend "s3" {
    bucket         = "template-tfstate-bucket"
    key            = "template/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "template-tfstate-lock"
  }
}
