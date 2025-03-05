# Source(s):
# - https://medium.com/@m.farhatmaher/how-to-deploy-a-dash-app-on-aws-lambda-with-terraform-cbaa2f2bf9b1
# - https://atsss.medium.com/small-lambda-function-with-python-and-terraform-f3100015f970 

# Create a REST API Gateway
resource "aws_api_gateway_rest_api" "ims_api" {
  name        = "ims-rest-api"
  description = "REST API Gateway for the Inventory Management System"
  body = templatefile("${path.module}/openapi.yaml",{
    move_stock_item_arn = module.move_store_item.lambda_function_invoke_arn
  })
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# Root resource to catch all requests so it would always be /hello/
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  parent_id   = aws_api_gateway_rest_api.ims_api.root_resource_id
  path_part   = "hello"
}

# An example ethod for the root resource
resource "aws_api_gateway_method" "hello_method" {
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# An example integration with a Lambda function
resource "aws_api_gateway_integration" "hello_lambda_integration" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_method.http_method

  integration_http_method = "POST"      # AWS_PROXY requires a POST method
  type                    = "AWS_PROXY" # Direct integration with Lambda
  uri                     = module.hello_world.lambda_function_invoke_arn
}

# An example method success response (Status code 200)
resource "aws_api_gateway_method_response" "hello_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_method.http_method
  status_code = "200" # Status code indicating a successful response

  response_parameters = {
    "method.response.header.Content-Type" = true # Indicates that the response will include this header
  }
}

# An example integration success response (Status code 200)
resource "aws_api_gateway_integration_response" "hello_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_method.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Content-Type" = "'application/json'" # Ensure the content type is set
  }

  depends_on = [aws_api_gateway_integration.hello_lambda_integration]
}

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "ims_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id

  # Trigger the deployment when the resources change
  # Note: Triggers are prefered over explicitly listed depends_on dependencies
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.hello_resource.id,
      aws_api_gateway_method.hello_method.id,
      aws_api_gateway_integration.hello_lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Create a stage for the deployment
resource "aws_api_gateway_stage" "ims_api_stage_deployment" {
  deployment_id = aws_api_gateway_deployment.ims_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id

  stage_name = "dev"
}