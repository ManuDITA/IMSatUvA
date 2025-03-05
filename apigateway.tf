# Source(s):
# - https://medium.com/@m.farhatmaher/how-to-deploy-a-dash-app-on-aws-lambda-with-terraform-cbaa2f2bf9b1
# - https://atsss.medium.com/small-lambda-function-with-python-and-terraform-f3100015f970 

# ---------------------------------------------------------
# Create a REST API Gateway
# ---------------------------------------------------------
resource "aws_api_gateway_rest_api" "ims_api" {
  name        = "ims-rest-api.${terraform.workspace}"
  description = "REST API Gateway for the Inventory Management System"

  body = jsonencode(yamldecode(templatefile("${path.module}/openapi.yaml", {
    move_stock_item_arn = module.move_store_item.lambda_function_invoke_arn
  })))

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ---------------------------------------------------------
# Create a Cognito User Pool Authorizer
# ---------------------------------------------------------
resource "aws_api_gateway_authorizer" "cognito_token_authorizer" {
  name            = "cognito-token-auth"
  rest_api_id     = aws_api_gateway_rest_api.ims_api.id
  type            = "COGNITO_USER_POOLS"
  identity_source = "method.request.header.Authorization"
  provider_arns   = [aws_cognito_user_pool.ims_user_pool.arn]
}

# ---------------------------------------------------------
# Test endpoints to verify authentication and authorization
# ---------------------------------------------------------
resource "aws_api_gateway_resource" "ims_api_auth" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  parent_id   = aws_api_gateway_rest_api.ims_api.root_resource_id
  path_part   = "auth_test"
}

resource "aws_api_gateway_method" "ims_api_auth_method" {
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id
  resource_id   = aws_api_gateway_resource.ims_api_auth.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_token_authorizer.id
}

resource "aws_api_gateway_integration" "ims_api_auth_integration" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.ims_api_auth.id
  http_method = aws_api_gateway_method.ims_api_auth_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.auth_test_user.lambda_function_invoke_arn
}

resource "aws_api_gateway_method_response" "ims_api_auth_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.ims_api_auth.id
  http_method = aws_api_gateway_method.ims_api_auth_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "ims_api_auth_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.ims_api_auth.id
  http_method = aws_api_gateway_method.ims_api_auth_method.http_method
  status_code = "200"

  depends_on = [aws_api_gateway_integration.ims_api_auth_integration]
}

// --------------------------------------------------------
resource "aws_api_gateway_resource" "ims_api_auth_admin" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  parent_id   = aws_api_gateway_rest_api.ims_api.root_resource_id
  path_part   = "auth_test_admin"
}

resource "aws_api_gateway_method" "ims_api_auth_admin_method" {
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id
  resource_id   = aws_api_gateway_resource.ims_api_auth_admin.id
  http_method   = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_token_authorizer.id
}

resource "aws_api_gateway_integration" "ims_api_auth_admin_integration" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.ims_api_auth_admin.id
  http_method = aws_api_gateway_method.ims_api_auth_admin_method.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = module.auth_test_admin.lambda_function_invoke_arn
}

resource "aws_api_gateway_method_response" "ims_api_auth_admin_method_response" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.ims_api_auth_admin.id
  http_method = aws_api_gateway_method.ims_api_auth_admin_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "ims_api_auth_admin_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id
  resource_id = aws_api_gateway_resource.ims_api_auth_admin.id
  http_method = aws_api_gateway_method.ims_api_auth_admin_method.http_method
  status_code = "200"

  depends_on = [aws_api_gateway_integration.ims_api_auth_admin_integration]
}

# ---------------------------------------------------------
# Deploy the API Gateway
# ---------------------------------------------------------
resource "aws_api_gateway_deployment" "ims_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id

  # Trigger the deployment when the resources change
  triggers = {
    redeployment = sha1(jsonencode((aws_api_gateway_rest_api.ims_api.body)))
  }

  depends_on = [aws_api_gateway_rest_api.ims_api]

  lifecycle {
    create_before_destroy = true
  }
}

# ---------------------------------------------------------
# Create a stage for the deployment
# ---------------------------------------------------------
resource "aws_api_gateway_stage" "ims_api_stage_deployment" {
  deployment_id = aws_api_gateway_deployment.ims_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id

  stage_name = "dev"
}
