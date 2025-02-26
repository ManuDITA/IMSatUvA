
module "hello_world" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "hello_world"
  description   = "Testing if the API gateway works as a first trial to set up a lambda in an API gateway"
  handler       = "hello_world.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path   = "${path.module}/lambdas/hello_world/"
  publish       = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}
