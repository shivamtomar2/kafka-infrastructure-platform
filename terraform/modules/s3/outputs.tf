output "bucket_name" {
  description = "Kafka artifacts S3 bucket name"
  value       = aws_s3_bucket.kafka_artifacts.bucket
}
