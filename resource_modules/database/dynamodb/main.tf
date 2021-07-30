########################################
# AWS DynamoDB resource module
#
# https://www.terraform.io/docs/providers/aws/r/dynamodb_table.html
########################################

resource "aws_dynamodb_table" "this" {
  name           = var.name
  read_capacity  = var.read_capacity
  write_capacity = var.write_capacity
  hash_key       = var.hash_key
  attribute {
    name = var.attribute_name
    type = var.attribute_type
  }

  server_side_encryption {
    enabled = var.sse_enabled
  }

  tags = var.tags
}
