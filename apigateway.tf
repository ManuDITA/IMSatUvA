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
    get_all_items_arn         = module.get_all_items.lambda_function_invoke_arn
    register_item_arn         = module.register_item.lambda_function_invoke_arn
    get_item_arn              = module.get_item.lambda_function_invoke_arn
    delete_item_arn           = module.delete_item.lambda_function_invoke_arn
    get_all_stores_arn        = module.get_all_stores.lambda_function_invoke_arn
    add_store_arn             = module.add_store.lambda_function_invoke_arn
    get_store_arn             = module.get_store.lambda_function_invoke_arn
    delete_store_arn          = module.delete_store.lambda_function_invoke_arn
    auth_test_user_arn        = module.auth_test_user.lambda_function_invoke_arn
    auth_test_admin_arn       = module.auth_test_admin.lambda_function_invoke_arn
    get_credentials_arn       = module.get_credentials.lambda_function_invoke_arn
    promote_user_arn          = module.promote_user.lambda_function_invoke_arn
    demote_user_arn           = module.demote_user.lambda_function_invoke_arn
    cognito_user_pool_arn     = aws_cognito_user_pool.ims_user_pool.arn
    get_cart_arn              = module.get_cart.lambda_function_invoke_arn
    add_item_to_cart_arn      = module.add_item_to_cart.lambda_function_invoke_arn 
    move_store_item_arn       = module.move_store_item.lambda_function_invoke_arn
    remove_item_from_cart_arn = module.remove_item_from_cart.lambda_function_invoke_arn
  })))

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

# ---------------------------------------------------------
# Deploy the API Gateway
# ---------------------------------------------------------
resource "aws_api_gateway_deployment" "ims_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id

  # Trigger the deployment when the resources change
  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.ims_api.body)
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [aws_api_gateway_rest_api.ims_api]
}

# ---------------------------------------------------------
# Create a stage for the deployment
# ---------------------------------------------------------
resource "aws_api_gateway_stage" "ims_api_stage_deployment" {
  stage_name    = "dev"
  deployment_id = aws_api_gateway_deployment.ims_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id
}
