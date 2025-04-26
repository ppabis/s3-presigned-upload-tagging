variable "table_name" {
  type        = string
  description = "Name of the DynamoDB table"
}

resource "aws_dynamodb_table" "items" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uid"

  attribute {
    name = "uid"
    type = "S"
  }

  ttl {
    attribute_name = "expireAt"
    enabled        = true
  }
}