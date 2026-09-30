provider "aws" {
  region = var.aws_region
}

module "test_bucket" {
  source        = "../component"
  bucket_prefix = var.bucket_prefix

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "Blueprint test"
  }
}