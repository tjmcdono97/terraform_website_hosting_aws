# Create the logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = "logs.${var.site_domain}"
}

resource "aws_s3_bucket_ownership_controls" "logging_bucket_ownership_controls" {
  bucket = aws_s3_bucket.logging_bucket.id

  rule {
    object_ownership = "ObjectWriter"
  }
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.logging_bucket.id
  acl    = "log-delivery-write"
}

resource "aws_s3_bucket_versioning" "versioning_logging" {
  bucket = aws_s3_bucket.logging_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable logging for the main static website bucket
resource "aws_s3_bucket_logging" "website_logging" {
  bucket = aws_s3_bucket.www.id

  target_bucket = aws_s3_bucket.logging_bucket.id

  # Optional: Set a prefix for the log files
  target_prefix = "logs/"
}