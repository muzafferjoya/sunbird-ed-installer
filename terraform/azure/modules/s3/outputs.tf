output "aws_s3_bucket_name" {
  value = aws_s3_bucket.example_bucket.bucket
}

output "aws_s3_bucket_arn" {
  value = aws_s3_bucket.example_bucket.arn
}

output "aws_s3_bucket_region" {
  value = aws_s3_bucket.example_bucket.region
}

output "aws_s3_bucket_domain_name" {
  value = aws_s3_bucket.example_bucket.bucket_domain_name
}
