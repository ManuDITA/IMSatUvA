
module "hello_world" {
  source                            = "terraform-aws-modules/lambda/aws"
  version                           = "7.20.0"
  function_name                     = "hello_world"
  description                       = "Testing if the API gateway works as a first trial to set up a lambda in an API gateway"
  handler                           = "hello_world.lambda_handler"
  runtime                           = "python3.9"
  architectures                     = ["arm64"]
  timeout                           = 120
  source_path                       = "${path.module}/lambdas/hello_world/"
  cloudwatch_logs_retention_in_days = 0

  #specifies that api_gateway can invoke the lambda
  allowed_triggers = {
    api_gateway = {
      statement_id  = "AllowAPIGatewayInvoke"
      action        = "lambda:InvokeFunction"
      function_name = "hello_world"
      principal     = "apigateway.amazonaws.com"
      source_arn    = "${aws_api_gateway_rest_api.ImsApi.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}
