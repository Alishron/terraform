output "bucket_name" {
  description = "Name of the test S3 bucket."
  value       = module.test_bucket.bucket_name
}

output "bucket_arn" {
  description = "ARN of the test S3 bucket."
  value       = module.test_bucket.bucket_arn
}