# Lambda Assume config

data "aws_iam_policy_document" "LambdaAssumeRole" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "LambdaPhotosRole" {
  name               = "LambdaPhotosRole"
  assume_role_policy = data.aws_iam_policy_document.LambdaAssumeRole.json
}

# Lambda actual outgoing permissions
# - S3 read/write
# - DynamoDB read/write

data "aws_iam_policy_document" "LambdaPhotosPermissions" {
  statement {
    actions   = ["s3:ListBucket", "s3:GetBucketLocation"]
    resources = [aws_s3_bucket.images.arn]
  }
  statement {
    actions   = ["s3:GetObject", "s3:GetObject*", "s3:PutObject", "s3:PutObject*"]
    resources = ["${aws_s3_bucket.images.arn}/*"]
  }
  statement {
    actions   = ["dynamodb:GetItem", "dynamodb:PutItem", "dynamodb:DeleteItem"]
    resources = [aws_dynamodb_table.items.arn]
  }
}

resource "aws_iam_role_policy" "LambdaPhotosPermissions" {
  role   = aws_iam_role.LambdaPhotosRole.name
  policy = data.aws_iam_policy_document.LambdaPhotosPermissions.json
}

resource "aws_iam_role_policy_attachment" "LambdaBasicExecutionRole" {
  role       = aws_iam_role.LambdaPhotosRole.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}