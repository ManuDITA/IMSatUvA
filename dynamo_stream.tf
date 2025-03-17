data "aws_dynamodb_table" "store" {
  name = "store" 
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream_trigger" {
  event_source_arn  = data.aws_dynamodb_table.store.stream_arn
  function_name     = "notify_user-${terraform.workspace}" 
  starting_position = "LATEST" 
}

resource "aws_lambda_event_source_mapping" "dynamodb_stream_trigger" {
  event_source_arn  = data.aws_dynamodb_table.store.stream_arn
  function_name     = "notify_admin-${terraform.workspace}" 
  starting_position = "LATEST" 
}
