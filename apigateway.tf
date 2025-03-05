# Source(s):
# - https://medium.com/@m.farhatmaher/how-to-deploy-a-dash-app-on-aws-lambda-with-terraform-cbaa2f2bf9b1
# - https://atsss.medium.com/small-lambda-function-with-python-and-terraform-f3100015f970 
c

# Deploy the API Gateway
resource "aws_api_gateway_deployment" "ims_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id

  # Trigger the deployment when the resources change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_rest_api.ims_api.body
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
  depends_on = [ aws_api_gateway_rest_api.ims_api ]
  
}

# Create a stage for the deployment
resource "aws_api_gateway_stage" "ims_api_stage_deployment" {
  deployment_id = aws_api_gateway_deployment.ims_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id

  stage_name = "dev"
}
