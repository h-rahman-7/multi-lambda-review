provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket  = "nasim-tf-state"
    region  = "eu-west-2"
    key     = "lambda_deploy"
    encrypt = true

  }
}