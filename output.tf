output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "invoke_url" {
  value = "${aws_api_gateway_rest_api.ims_api.execution_arn}/hello"
}

output "cognito_user_pool_arn" {
  value = aws_cognito_user_pool.ims_user_pool.arn
}

output "lambda_function_move_store_item_invoke_arn" {
  value = module.move_store_item.lambda_function_invoke_arn
}

output "lambda_function_auth_test_user_invoke_arn" {
  value = module.auth_test_user.lambda_function_invoke_arn
}

output "lambda_function_auth_test_admin_invoke_arn" {
  value = module.auth_test_admin.lambda_function_invoke_arn
}

output "lambda_function_get_credentials_invoke_arn" {
  value = module.get_credentials.lambda_function_invoke_arn
}

output "lambda_function_promote_user_invoke_arn" {
  value = module.promote_user.lambda_function_invoke_arn
}

output "lambda_function_demote_user_invoke_arn" {
  value = module.demote_user.lambda_function_invoke_arn
}

output "lambda_function_get_all_items_invoke_arn" {
  value = module.get_all_items.lambda_function_invoke_arn
}

output "lambda_function_register_item_invoke_arn" {
  value = module.register_item.lambda_function_invoke_arn
}

output "lambda_function_get_item_invoke_arn" {
  value = module.get_item.lambda_function_invoke_arn
}

output "lambda_function_delete_item_invoke_arn" {
  value = module.delete_item.lambda_function_invoke_arn
}

output "lambda_function_get_stores_invoke_arn" {
  value = module.get_all_stores.lambda_function_invoke_arn
}

output "lambda_function_add_store_invoke_arn" {
  value = module.add_store.lambda_function_invoke_arn
}

output "lambda_function_get_store_invoke_arn" {
  value = module.get_store.lambda_function_invoke_arn
}

output "lambda_function_delete_store_invoke_arn" {
  value = module.delete_store.lambda_function_invoke_arn
}

output "lambda_function_get_cart_invoke_arn" {
  value = module.get_cart.lambda_function_invoke_arn
}

output  "lambda_function_add_item_to_cart_invoke_arn"{
  value = module.add_item_to_cart.lambda_function_invoke_arn
}

output "lambda_function_reserve_item_invoke_arn" {
  value = module.reserve_item.lambda_function_invoke_arn
  
}
