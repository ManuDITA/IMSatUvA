# Source(s):
# - https://medium.com/@m.farhatmaher/how-to-deploy-a-dash-app-on-aws-lambda-with-terraform-cbaa2f2bf9b1
# - https://atsss.medium.com/small-lambda-function-with-python-and-terraform-f3100015f970 

# Create a REST API Gateway
/* resource "aws_api_gateway_rest_api" "ims_api" {
  name        = "ims-rest-api.${terraform.workspace}"
  description = "REST API Gateway for the Inventory Management System"

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "example"
      version = "1.0"
    }
    paths = {
      "/stores/{storeId}/stock/{itemId}" = {
        post = {
          tags        = ["store"]
          summary     = "Move an item from one store to another"
          operationId = "moveStockItem"
          parameters = {
            storeId = {
              name     = "storeId"
              in       = "path"
              required = true
              schema = {
                type   = "string"
                format = "uuid"
              }
            }
            itemId = {
              name     = "itemId"
              in       = "path"
              required = true
              schema = {
                type   = "string"
                format = "uuid"
              }
            }
          }
          requestBody = {
            content = {
              "application/json" = {
                schema = {
                  type = "object"
                  properties = {
                    quantity = {
                      type   = "integer"
                      format = "int32"
                    }
                    toStore = {
                      type   = "string"
                      format = "uuid"
                    }
                  }
                }
              }
            }
          }
          responses = {
            "200" = {
              description = "200 response"
            }
          }
          x-amazon-apigateway-integration = {
            type                = "aws_proxy"
            httpMethod          = "POST"
            uri                 = module.move_store_item.lambda_function_invoke_arn
            passthroughBehavior = "when_no_match"
          }
        }
      }
    }
  })

  endpoint_configuration {
    types = ["REGIONAL"]
  }
} */

resource "aws_api_gateway_rest_api" "ims_api" {
  name        = "ims-rest-api.${terraform.workspace}"
  description = "REST API Gateway for the Inventory Management System"

  body = jsonencode(yamldecode(templatefile("${path.module}/openapi.yaml", {
    move_stock_item_arn = module.move_store_item.lambda_function_invoke_arn
  })))

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# Deploy the API Gateway
resource "aws_api_gateway_deployment" "ims_api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.ims_api.id

  # Trigger the deployment when the resources change
  triggers = {
    redeployment = sha1(aws_api_gateway_rest_api.ims_api.body)
  }

  depends_on = [aws_api_gateway_rest_api.ims_api]

  lifecycle {
    create_before_destroy = true
  }
}

# Create a stage for the deployment
resource "aws_api_gateway_stage" "ims_api_stage_deployment" {
  deployment_id = aws_api_gateway_deployment.ims_api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ims_api.id

  stage_name = "dev"
}
