#iam role for lambda to assume
resource "aws_iam_role" "lambda_exec_role" {
  name = "lambda-exec-role-${terraform.workspace}"

  assume_role_policy = jsonencode({ # policy that specifies which entities can assume
    Version = "2012-10-17",
    Statement = [{
      Effect    = "Allow",
      Principal = { Service = "lambda.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [name, assume_role_policy]
  }
}

#attach predefined policy tp previously created role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.lambda_exec_role]
}

resource "aws_lambda_permission" "allow_api_gateway" {
  for_each = {
    for fn in [module.move_store_item] : fn.function_name => fn
  }

  statement_id  = "${each.key}-allow-api-gateway"
  action        = "lambda:InvokeFunction"
  function_name = each.value.function_name
  principal     = "apigateway.amazonaws.com"

  # This ARN allows API Gateway to invoke the Lambda function
  source_arn    = "${aws_api_gateway_rest_api.ims_api.execution_arn}/*/*"
}
