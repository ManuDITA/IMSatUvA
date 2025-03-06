output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "invoke_url" {
  value = "${aws_api_gateway_rest_api.ims_api.execution_arn}/hello"
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
