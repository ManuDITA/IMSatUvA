#source : https://medium.com/@m.farhatmaher/how-to-deploy-a-dash-app-on-aws-lambda-with-terraform-cbaa2f2bf9b1 ,
#source : https://atsss.medium.com/small-lambda-function-with-python-and-terraform-f3100015f970 

resource "aws_api_gateway_rest_api" "ImsApi" {
    name = "Inventory-management-rest-api"
    description = "Api Gateway Rest API for Inventory Management prototype"

    endpoint_configuration {
      types = ["REGIONAL"]
    }
}

#root resource to catch all requests so it would always be /inventoryManagement/
resource "aws_ImsApi_resource" "inventoryManagement" {
    rest_api_id = aws_api_gateway_rest_api.ImsApi.id
    parent_id = aws_api_gateway_rest_api.ImsApi.root_resource_id
    path_part = "{inventoryManagement+}" #catch-all path for the API
}

#method for the api resource which means the method will respond to ANY requests
resource "aws_ImsApi_method" "inventoryManagement_method" {
    rest_api_id = aws_api_gateway_rest_api.ImsApi.id
    resource_id = aws_api_gateway_resource.inventoryManagement.id
    http_method = "ANY"
    authorization = "NONE"
}


resource "aws_ImsApi_integration" "hello_lambda_integration" {
  # Integrate root proxy with the Lambda function
  rest_api_id             = aws_api_gateway_rest_api.ImsApi.id
  resource_id             = aws_api_gateway_method.inventoryManagement.id
  http_method             = aws_api_gateway_method.inventoryManagement_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY" # Direct integration with Lambda
  uri                     = module.hello-world.lambda_function_invoke_arn
}
