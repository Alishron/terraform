provider "aws" {
  region = "us-east-1"
}

module "bucket" {
  source        = "../../component"
  bucket_prefix = var.bucket_prefix
  tags = {
    Environment = var.environment
  }
}