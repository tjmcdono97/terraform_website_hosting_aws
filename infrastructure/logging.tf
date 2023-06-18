# Create the logging bucket
resource "aws_s3_bucket" "logging_bucket" {
  bucket = var.logging_bucket

  notification {
    queue {
      queue_arn     = aws_sqs_queue.notification_queue.arn
      events        = ["s3:ObjectCreated:*"]
      filter_suffix = ".log"
    }
  }
}

# Enable logging for the main static website bucket
resource "aws_s3_bucket_logging" "website_logging" {
  bucket = aws_s3_bucket.site.id

  target_bucket = aws_s3_bucket.logging_bucket.id

  # Optional: Set a prefix for the log files
  target_prefix = "logs/"
}