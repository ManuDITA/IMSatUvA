resource "aws_lambda_layer_version" "lambda_layer" {
  filename            = "${path.module}/layers/lambda_layer.zip"
  layer_name          = "lambda-layer"
  compatible_runtimes = ["python3.13"]
}