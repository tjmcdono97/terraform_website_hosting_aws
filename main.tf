# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {}

resource "aws_s3_bucket" "site" {
  bucket = var.site_domain
}

resource "aws_s3_bucket_public_access_block" "access_block" {
  bucket = aws_s3_bucket.site.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "site" {
  bucket = aws_s3_bucket.site.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}


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

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site_domain}"
}

resource "aws_s3_bucket_public_access_block" "www_access_block" {
  bucket = aws_s3_bucket.www.id

  block_public_acls   = false
  block_public_policy = false
  ignore_public_acls  = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id

  redirect_all_requests_to {
    host_name = var.site_domain
  }
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.site_domain
  value   = aws_s3_bucket_website_configuration.site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "www"
  value   = var.site_domain
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

resource "cloudflare_page_rule" "https" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  target  = "*.${var.site_domain}/*"
  actions {
    always_use_https = true
  }
}


resource "aws_s3_bucket_object" "html" {
  for_each = fileset("${path.module}/html", "**/*")

  bucket       = aws_s3_bucket.site.id
  key          = each.key
  source       = "${path.module}/html/${each.key}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1], "text/plain")
  etag         = filemd5("${path.module}/html/${each.key}")
}

locals {
  mime_types = {
    "aac"    = "audio/aac",
    "abw"    = "application/x-abiword",
    "arc"    = "application/x-freearc",
    "avi"    = "video/x-msvideo",
    "azw"    = "application/vnd.amazon.ebook",
    "bin"    = "application/octet-stream",
    "bmp"    = "image/bmp",
    "bz"     = "application/x-bzip",
    "bz2"    = "application/x-bzip2",
    "csh"    = "application/x-csh",
    "css"    = "text/css",
    "csv"    = "text/csv",
    "doc"    = "application/msword",
    "docx"   = "application/vnd.openxmlformats-officedocument.wordprocessingml.document",
    "eot"    = "application/vnd.ms-fontobject",
    "epub"   = "application/epub+zip",
    "gz"     = "application/gzip",
    "gif"    = "image/gif",
    "htm"    = "text/html",
    "html"   = "text/html",
    "ico"    = "image/vnd.microsoft.icon",
    "ics"    = "text/calendar",
    "jar"    = "application/java-archive",
    "jpeg"   = "image/jpeg",
    "jpg"    = "image/jpeg",
    "js"     = "text/javascript",
    "json"   = "application/json",
    "jsonld" = "application/ld+json",
    "mid"    = "audio/x-midi",
    "midi"   = "audio/x-midi",
    "mjs"    = "text/javascript",
    "mp3"    = "audio/mpeg",
    "mpeg"   = "video/mpeg",
    "mpkg"   = "application/vnd.apple.installer+xml",
    "odp"    = "application/vnd.oasis.opendocument.presentation",
    "ods"    = "application/vnd.oasis.opendocument.spreadsheet",
    "odt"    = "application/vnd.oasis.opendocument.text",
    "oga"    = "audio/ogg",
    "ogv"    = "video/ogg",
    "ogx"    = "application/ogg",
    "opus"   = "audio/opus",
    "otf"    = "font/otf",
    "png"    = "image/png",
    "pdf"    = "application/pdf",
    "php"    = "application/x-httpd-php",
    "ppt"    = "application/vnd.ms-powerpoint",
    "pptx"   = "application/vnd.openxmlformats-officedocument.presentationml.presentation",
    "rar"    = "application/vnd.rar",
    "rtf"    = "application/rtf",
    "sh"     = "application/x-sh",
    "svg"    = "image/svg+xml",
    "swf"    = "application/x-shockwave-flash",
    "tar"    = "application/x-tar",
    "tif"    = "image/tiff",
    "tiff"   = "image/tiff",
    "ts"     = "video/mp2t",
    "ttf"    = "font/ttf",
    "txt"    = "text/plain",
    "vsd"    = "application/vnd.visio",
    "wav"    = "audio/wav",
    "weba"   = "audio/webm",
    "webm"   = "video/webm",
    "webp"   = "image/webp",
    "woff"   = "font/woff",
    "woff2"  = "font/woff2",
    "xhtml"  = "application/xhtml+xml",
    "xls"    = "application/vnd.ms-excel",
    "xlsx"   = "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
    "xml"    = "text/xml",
    "xul"    = "application/vnd.mozilla.xul+xml",
    "zip"    = "application/zip",
    "7z"     = "application/x-7z-compressed",
    "yaml"   = "application/x-yaml",
    "scss"   = "text/plain",
    "md"     = "text/markdown",
  }
}