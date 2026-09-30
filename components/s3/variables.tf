variable "bucket_prefix" {
  description = "Prefix used for the globally unique S3 bucket name."
  type        = string

  validation {
    condition     = length(var.bucket_prefix) >= 3 && length(var.bucket_prefix) <= 37 && can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.bucket_prefix))
    error_message = "bucket_prefix must be 3-37 lowercase letters, numbers, or hyphens and start/end with a letter or number."
  }
}

variable "environment" {
  description = "Environment tag applied to the S3 bucket."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}