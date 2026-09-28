variable "bucket_prefix" {
  description = "Prefix used for the globally unique S3 bucket name."
  type        = string

  validation {
    condition     = length(var.bucket_prefix) >= 3 && length(var.bucket_prefix) <= 37
    error_message = "bucket_prefix must be between 3 and 37 characters."
  }
}

variable "tags" {
  description = "Tags applied to the S3 bucket."
  type        = map(string)
  default     = {}
}