
output "lambda_function_hello_world_invoke_arn" { 
    value = module.hello_world.lambda_function_invoke_arn
}
output "lambda_function_move_store_item_invoke_arn" { 
    value = module.move_store_item.lambda_function_invoke_arn
}
