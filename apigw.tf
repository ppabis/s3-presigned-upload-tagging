variable "api_name" {
  type        = string
  description = "Name of the API Gateway"
}

resource "aws_api_gateway_rest_api" "api" {
  name = var.api_name
}

resource "aws_api_gateway_method" "get" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_rest_api.api.root_resource_id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get-list" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_rest_api.api.root_resource_id
  http_method = aws_api_gateway_method.get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda["list"].invoke_arn
}

resource "aws_api_gateway_stage" "prod" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"
  deployment_id = aws_api_gateway_deployment.prod.id
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.api.id

  depends_on = [
    aws_api_gateway_integration.get-list
  ]

  variables = {
    "deployed_version" = "1" # Change this to force deployment, otherwise you have to do it manually
  }
}

output "api-gateway" {
  value = aws_api_gateway_deployment.prod.invoke_url
}