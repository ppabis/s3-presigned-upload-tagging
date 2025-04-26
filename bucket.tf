variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

resource "aws_s3_bucket" "images" {
  bucket        = var.bucket_name
  force_destroy = true
}