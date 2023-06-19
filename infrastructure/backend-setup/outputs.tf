output "bucket_name" {
  value = aws_s3_bucket.terraform_state.id
  description = "The name of the S3 bucket to be used for Terraform state storage"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_locks.name
  description = "The name of the DynamoDB table to be used for Terraform state locking"
}