variable "bucket_name" {
  type        = string
  description = "Name of the S3 bucket"
}

resource "aws_s3_bucket" "images" {
  bucket        = var.bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "images" {
  bucket              = aws_s3_bucket.images.id
  block_public_policy = false
}

resource "aws_s3_bucket_policy" "bucket-policy" {
  depends_on = [aws_s3_bucket_public_access_block.images]
  bucket     = aws_s3_bucket.images.id
  policy     = <<-EOF
  { 
    "Version": "2012-10-17",
    "Statement": [ {
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "${aws_s3_bucket.images.arn}/*"
      } ]
  }
  EOF
}

resource "aws_s3_bucket_cors_configuration" "allow-all-origins" {
  bucket = aws_s3_bucket.images.id
  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
    max_age_seconds = 600
  }
}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = aws_s3_bucket.images.id
  lambda_function {
    lambda_function_arn = aws_lambda_function.lambda["tag"].arn
    events              = ["s3:ObjectCreated:*"]
  }
  depends_on = [ aws_lambda_permission.s3 ]
}