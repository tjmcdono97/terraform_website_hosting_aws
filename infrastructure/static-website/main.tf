# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

# Define AWS as the provider with the specified region
provider "aws" {
  region = var.aws_region
}

terraform {
  backend "s3" {
    bucket         = "kc-equine-services-terraform-state"
    key            = "terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-up-and-running-locks"
    encrypt        = true
  }
}


# Define Cloudflare as a provider (assuming authentication is already configured)

# Create an S3 bucket for the site
resource "aws_s3_bucket" "site" {
  bucket = var.site_domain
  # Adding logging

  # Adding tags
  tags = {
    Owner       = var.Owner
    Project     = var.Project
  }
}

resource "aws_s3_bucket_versioning" "versioning_site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}


# Configure public access settings for the site bucket
resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure the website hosting settings for the site bucket
resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}

# Configure the bucket policy to allow public read access to objects
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*",
        ]
      },
    ]
  })
}

# Create an S3 bucket for the "www" subdomain
resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site_domain}"

}

resource "aws_s3_bucket_versioning" "versioning_www" {
  bucket = aws_s3_bucket.www.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Configure public access settings for the www bucket
resource "aws_s3_bucket_public_access_block" "www_access_block" {
  bucket = aws_s3_bucket.www.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

# Configure the website hosting settings for the www bucket with a redirect
resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  redirect_all_requests_to {
    host_name = var.site_domain
  }
}

# Query Cloudflare for the domain zone
data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

# Create a Cloudflare record to map the site domain to the S3 bucket endpoint
resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.site_domain
  value   = aws_s3_bucket_website_configuration.site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

# Create a Cloudflare record for the "www" subdomain
resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "www"
  value   = var.site_domain
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

# Create a Cloudflare page rule to enforce HTTPS for all URLs
resource "cloudflare_page_rule" "https" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  target  = "*.${var.site_domain}/*"
  actions {
    always_use_https = true
  }
}

# Upload HTML files to the site S3 bucket
resource "aws_s3_bucket_object" "html" {
  for_each = fileset("${path.module}/../../html", "**/*")

  bucket       = aws_s3_bucket.site.id
  key          = each.key
  source       = "${path.module}/../../html/${each.key}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "text/plain")
  etag         = filemd5("${path.module}/../../html/${each.key}")
}

# Define local variable for MIME types
locals {
  mime_types = {
    "html"   = "text/html",
    "jpeg"   = "image/jpeg",
    "jpg"    = "image/jpeg",
    "png"    = "image/png",
    "css"    = "text/css"
  }
}

