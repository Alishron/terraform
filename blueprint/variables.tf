variable "aws_region" {
  description = "AWS region in which to create the test bucket."
  type        = string
}

variable "bucket_prefix" {
  description = "Prefix for the globally unique S3 bucket name."
  type        = string
}