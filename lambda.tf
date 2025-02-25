
module "hello-world"{
    source        = "terraform-aws-modules/lambda/aws"
    version       = "7.20.0"
    function_name = "hello-world-lambda"
    description   = "Testing if the API gateway works as a first trial to set up a lambda in an API gateway"
    handler       = "hello-world.lambda_handler"
    runtime       = "python3.11"
    architectures = ["arm64"]  
    timeout = 120
    source_path = "${path.module}/../lambda/hello-world/hello-world.zip"
    attach_cloudwatch_logs_policy = true
    cloudwatch_logs_retention_in_days = 14

    #specifies that api_gateway can invoke the lambda
    allowed_triggers = {
        api_gateway = {
            statement_id  = "AllowAPIGatewayInvoke"
            action        = "lambda:InvokeFunction"
            function_name = module.hello-world.lambda_function_arn
            principal     = "apigateway.amazonaws.com"
            source_arn    = "${aws_api_gateway_rest_api.ImsApi.execution_arn}/*/*" # Allow access from any method and path
        }
    }
}
