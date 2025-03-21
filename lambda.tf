module "hello_world" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "hello_world-${terraform.workspace}"
  description   = "Testing if the API gateway works as a first trial to set up a lambda in an API gateway"
  handler       = "hello_world.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
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

module "get_all_items" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "get_all_items-${terraform.workspace}"
  description   = "Get a list of all defined items"
  handler       = "get_all_items.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/get_all_items/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "register_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "register_item-${terraform.workspace}"
  description   = "Register a new item type"
  handler       = "register_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/register_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "delete_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "delete_item-${terraform.workspace}"
  description   = "Delete an item type"
  handler       = "delete_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/delete_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "get_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "get_item-${terraform.workspace}"
  description   = "Delete an item type"
  handler       = "get_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/get_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

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
  function_name = "auth_test_user-${terraform.workspace}"
  description   = "Testing if the lambda function can be invoked by any authenticated user via the API Gateway"
  handler       = "auth_test_user.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
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
  function_name = "auth_test_admin-${terraform.workspace}"
  description   = "Testing if the lambda function can be invoked by any authorized admin via the API Gateway"
  handler       = "auth_test_admin.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
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
  function_name = "get_credentials-${terraform.workspace}"
  description   = "Get the credentials of the user invoking the lambda function"
  handler       = "get_credentials.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path   = "${path.module}/lambdas/get_credentials/"
  publish       = true
  attach_policy = true
  policy        = aws_iam_policy.get_credentials_policy.arn

  environment_variables = {
    "IDENTITY_POOL_ID" = aws_cognito_identity_pool.ims_identity_pool.id
    "AWS_ACCOUNT_ID"   = data.aws_caller_identity.current.account_id
    "USER_POOL_ID"     = aws_cognito_user_pool.ims_user_pool.id
    "TF_AWS_REGION"    = var.aws_region
  }

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "promote_user" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "promote_user-${terraform.workspace}"
  description   = "Promote a user (Add a user to a group)"
  handler       = "promote_user.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path = [
    "${path.module}/lambdas/promote_user/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish       = true
  attach_policy = true
  policy        = aws_iam_policy.add_to_group_policy.arn

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }

  environment_variables = {
    "USER_POOL_ID" = aws_cognito_user_pool.ims_user_pool.id
  }
}

module "demote_user" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "demote_user-${terraform.workspace}"
  description   = "Demote a user (Remove a user from a group)"
  handler       = "demote_user.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  source_path = [
    "${path.module}/lambdas/demote_user/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish       = true
  attach_policy = true
  policy        = aws_iam_policy.add_to_group_policy.arn

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }

  environment_variables = {
    "USER_POOL_ID" = aws_cognito_user_pool.ims_user_pool.id
  }
}

module "get_all_stores" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "get_all_stores-${terraform.workspace}"
  description   = "Get a list of all defined stores"
  handler       = "get_all_stores.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/get_all_stores/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "add_store" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "add_store-${terraform.workspace}"
  description   = "Add a store"
  handler       = "add_store.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/add_store/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "get_store" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "get_store-${terraform.workspace}"
  description   = "Get a list of all defined stores"
  handler       = "get_store.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/get_store/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "delete_store" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "delete_store-${terraform.workspace}"
  description   = "Get a list of all defined stores"
  handler       = "delete_store.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/delete_store/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "add_store_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "add_store_item-${terraform.workspace}"
  description   = "Add existing item to a store"
  handler       = "add_store_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
    source_path = [
    "${path.module}/lambdas/add_store_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish       = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "delete_store_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "delete_store_item-${terraform.workspace}"
  description   = "Get a list of all defined stores"
  handler       = "delete_store_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/delete_store_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "update_store_item" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "update_store_item-${terraform.workspace}"
  description   = "Get a list of all defined stores"
  handler       = "update_store_item.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/update_store_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

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
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/move_store_item/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}
module "get_cart" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "get_cart-${terraform.workspace}"
  description   = "Get shopping cart"
  handler       = "get_cart.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/get_cart/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
}

module "add_item_to_cart" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "add_item_to_cart-${terraform.workspace}"
  description   = "Add item to shopping cart"
  handler       = "add_item_to_cart.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/add_item_to_cart/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
  
}

module "remove_item_from_cart" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "remove_item_from_cart-${terraform.workspace}"
  description   = "Add item to shopping cart"
  handler       = "remove_item_from_cart.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/remove_item_from_cart/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
  
}


module "reserve_stock" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "reserve_stock-${terraform.workspace}"
  description   = "reserve_item"
  handler       = "reserve_stock.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/reserve_stock/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true
  attach_policy = true
  policy        = aws_iam_policy.reserve_stock_sns_policy.arn

  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
  
}


module "notify_user" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "notify_user-${terraform.workspace}"
  description   = "notify_user"
  handler       = "notify_user.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/notify_user/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true
  attach_policy = true
  policy        = aws_iam_policy.reserve_stock_sns_policy.arn
  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }
  
}

module "notify_admin" {
  source        = "terraform-aws-modules/lambda/aws"
  version       = "7.20.0"
  function_name = "notify_admin-${terraform.workspace}"
  description   = "notify_admin"
  handler       = "notify_admin.lambda_handler"
  runtime       = "python3.13"
  architectures = ["arm64"]
  timeout       = 120
  create_role   = false
  lambda_role   = aws_iam_role.lambda_exec_role.arn
  source_path = [
    "${path.module}/lambdas/notify_admin/",
    {
      path          = "${path.module}/lambdas/modules/"
      prefix_in_zip = "modules"
    }
  ]
  publish = true
  # Allow the API Gateway to invoke the Lambda functions
  allowed_triggers = {
    APIGatewayAny = {
      service    = "apigateway"
      source_arn = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*" # Allow access from any method and path
    }
  }

  environment_variables = {
    "USER_POOL_ID" = aws_cognito_user_pool.ims_user_pool.id
  }
}