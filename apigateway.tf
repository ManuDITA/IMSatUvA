#source : https://medium.com/@m.farhatmaher/how-to-deploy-a-dash-app-on-aws-lambda-with-terraform-cbaa2f2bf9b1 ,
#source : https://atsss.medium.com/small-lambda-function-with-python-and-terraform-f3100015f970 

resource "aws_api_gateway_rest_api" "ImsApi" {
  name        = "Inventory-management-rest-api"
  description = "Api Gateway Rest API for Inventory Management prototype"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#root resource to catch all requests so it would always be /inventoryManagement/
resource "aws_api_gateway_resource" "hello_resource" {
  rest_api_id = aws_api_gateway_rest_api.ImsApi.id
  parent_id   = aws_api_gateway_rest_api.ImsApi.root_resource_id
  path_part   = "hello"
}

#method for the api resource which means the method will respond to ANY requests
resource "aws_api_gateway_method" "hello_method" {
  rest_api_id   = aws_api_gateway_rest_api.ImsApi.id
  resource_id   = aws_api_gateway_resource.hello_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "hello_lambda_integration" {
  # Integrate root proxy with the Lambda function
  rest_api_id = aws_api_gateway_rest_api.ImsApi.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Direct integration with Lambda
  uri                     = module.hello_world.lambda_function_invoke_arn
}

resource "aws_api_gateway_method_response" "hello_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ImsApi.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_method.http_method
  status_code = "200" # Status code indicating a successful response

  response_parameters = {
    "method.response.header.Content-Type" = true # Indicates that the response will include this header
  }
}

resource "aws_api_gateway_integration_response" "hello_lambda_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ImsApi.id
  resource_id = aws_api_gateway_resource.hello_resource.id
  http_method = aws_api_gateway_method.hello_method.http_method
  status_code = aws_api_gateway_method_response.hello_method_response.status_code

  response_parameters = {
    "method.response.header.Content-Type" = "'application/json'" # Ensure the content type is set
  }
}


resource "aws_api_gateway_deployment" "ims_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ImsApi.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_resource.hello_resource))
  }

  depends_on = [aws_api_gateway_integration.hello_lambda_integration]

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "ims_api_stage_deployment" {
  deployment_id = aws_api_gateway_deployment.ims_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ImsApi.id

  stage_name = "dev"
}