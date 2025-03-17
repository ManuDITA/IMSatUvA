resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "${path.module}/layer/python/lambda_layer.zip"
  layer_name          = "lambda-layer"
  compatible_runtimes = ["python3.13"]
}