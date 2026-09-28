provider "aws" {
  region = var.aws_region
}

module "test_bucket" {
  source        = "../component"
  bucket_prefix = "terraform-blueprint-test-"

  tags = {
    ManagedBy = "Terraform"
    Purpose   = "Blueprint test"
  }
}