resource "random_string" "bucket_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "aws_s3_bucket" "kafka_artifacts" {
  bucket = "${var.environment}-kafka-artifacts-${random_string.bucket_suffix.result}"

  tags = {
    Name        = "kafka-artifacts"
    Environment = var.environment
    Project     = "Kafka-Infrastructure-Platform"
  }
}
