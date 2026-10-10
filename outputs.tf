output "cloudfront_domain" {
  description = "Public entry point (expect HTTP 200)"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "bucket_regional_domain" {
  description = "Direct bucket endpoint (expect HTTP 403)"
  value       = aws_s3_bucket.site.bucket_regional_domain_name
}

output "bucket_name" {
  description = "Origin bucket name (used by teardown.sh)"
  value       = aws_s3_bucket.site.id
}

output "distribution_id" {
  value = aws_cloudfront_distribution.site.id
}
