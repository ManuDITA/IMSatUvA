output "invoke_url" {
  value = "${aws_api_gateway_rest_api.ImsApi.execution_arn}/hello"
}