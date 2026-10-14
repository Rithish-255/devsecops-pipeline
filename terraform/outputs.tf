output "bucket_name" {
  description = "Name of the S3 bucket created for artifacts"
  value       = aws_s3_bucket.artifact_store.bucket
}

output "bucket_arn" {
  description = "ARN of the S3 bucket created for artifacts"
  value       = aws_s3_bucket.artifact_store.arn
}
