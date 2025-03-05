
module "move_store_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "move_store_item"
  description   = "Move item from one store to another "
  handler       = "move_store_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path   = "${path.module}/lambdas/move_store_item/"
  publish       = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}
