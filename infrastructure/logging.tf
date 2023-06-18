# Create the logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket
}

# Enable logging for the main static website bucket
resource "aws_s3_bucket_logging" "website_logging" {
  bucket = aws_s3_bucket.main.id

  target_bucket = aws_s3_bucket.logging_bucket.id

  # Optional: Set a prefix for the log files
  target_prefix = "logs/"
}