variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
  default     = "us-east-1"
}

variable "site_domain" {
  type        = string
  description = "The domain name to use for the static site"
  default     = "www.site_domain.com"
}


variable "logging_bucket" {
  type        = string
  description = "The domain name to use for the static site"
  default     = "website-activity-logs"
}

variable "Project" {
  type        = string
  description = "Project Name"
  default     = "Static Website"
}

variable "Owner" {
  type        = string
  description = "Project Owner Name"
  default     = "1kalderson"
}
