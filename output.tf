output "lambda_function_move_store_item_invoke_arn" {
  value = module.move_store_item.lambda_function_invoke_arn
}

output "lambda_function_auth_test_user_invoke_arn" {
  value = module.auth_test_user.lambda_function_invoke_arn
}

output "lambda_function_auth_test_admin_invoke_arn" {
  value = module.auth_test_admin.lambda_function_invoke_arn
}
