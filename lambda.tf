data "archive_file" "zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambdas"
  output_path = "${path.module}/lambdas.zip"
}

data "aws_region" "current" {}

resource "aws_lambda_function" "lambda" {
  for_each = toset(["list", "tag", "upload"])

  function_name    = "photos-lambda-${each.key}"
  role             = aws_iam_role.LambdaPhotosRole.arn
  handler          = "${each.key}.lambda_handler"
  runtime          = "python3.12"
  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256
  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.images.bucket
      TABLE_NAME  = aws_dynamodb_table.items.name
      REDIRECT = "https://${aws_api_gateway_rest_api.api.id}.execute-api.${data.aws_region.current.name}.amazonaws.com/${var.stage_name}"
    }
  }
}

resource "aws_lambda_permission" "api" {
  for_each      = toset(["list", "upload"])
  function_name = aws_lambda_function.lambda[each.key].function_name
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*/*"
  principal     = "apigateway.amazonaws.com"
  action        = "lambda:InvokeFunction"
}

resource "aws_lambda_permission" "s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda["tag"].function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.images.arn
}
