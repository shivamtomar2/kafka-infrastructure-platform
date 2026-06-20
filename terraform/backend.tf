terraform {
  backend "s3" {
    bucket         = "shivam-kafka-terraform-state"
    key            = "assignment-05/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "shivam-kafka-terraform-locks"
    encrypt        = true
  }
}
