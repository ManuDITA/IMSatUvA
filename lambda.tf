module "hello_world" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "hello_world-${terraform.workspace}"
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

module "move_store_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "move_store_item-${terraform.workspace}"
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

module "auth_test_user" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "auth_test_user"
  description   = "Testing if the lambda function can be invoked by any authenticated user via the API Gateway"
  handler       = "auth_test_user.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path   = "${path.module}/lambdas/auth_test_user/"
  publish       = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "auth_test_admin" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "auth_test_admin"
  description   = "Testing if the lambda function can be invoked by any authorized admin via the API Gateway"
  handler       = "auth_test_admin.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path   = "${path.module}/lambdas/auth_test_admin/"
  publish       = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "get_credentials" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "get_credentials"
  description   = "Get the credentials of the user invoking the lambda function"
  handler       = "get_credentials.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path   = "${path.module}/lambdas/get_credentials/"
  publish       = true
  attach_policy = true
  policy        = aws_iam_policy.get_credentials_policy.arn

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }

  environment_variables = {
    "IDENTITY_POOL_ID" = aws_cognito_identity_pool.ims_identity_pool.id
    "TF_AWS_REGION"    = var.aws_region
  }
}
