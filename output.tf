output "invoke_url" {
  value = "${aws_api_gateway_rest_api.ims_api.execution_arn}/hello"
}

output "lambda_function_hello_world_invoke_arn" {
  value = module.hello_world.lambda_function_invoke_arn
}