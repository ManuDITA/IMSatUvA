resource "aws_lambda_layer_version" "dependencies_layer" {
  filename            = "lambda_layer.zip"
  layer_name          = "dependencies_layer"
  compatible_runtimes = ["python3.9", "python3.10"]
  source_code_hash    = filebase64sha256("lambda_layer.zip")
}
