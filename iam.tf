# Retrieve AWS Account ID
# Source: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity
data "aws_caller_identity" "current" {}

# IAM role for lambda to assume
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
    prevent_destroy = false
    ignore_changes  = [name, assume_role_policy]
  }
}

# Attach predefined policy tp previously created role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  depends_on = [aws_iam_role.lambda_exec_role]
}

# IAM role policy for lambda to interact with DynamoDB
resource "aws_iam_role_policy" "lambda_dynamodb_rw_policy" {
  name = "lambda-dynamodb-rw-${terraform.workspace}"
  role = aws_iam_role.lambda_exec_role.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "dynamodb:Scan",
        "dynamodb:PutItem",
        "dynamodb:GetItem",
        "dynamodb:UpdateItem",
        "dynamodb:DeleteItem",
        "dynamodb:DescribeTable"
      ],
      Resource = "arn:aws:dynamodb:${var.aws_region}:${data.aws_caller_identity.current.account_id}:table/*"
    }]
  })
}

# Get credentials lambda function policy
resource "aws_iam_policy" "get_credentials_policy" {
  name        = "get-credentials-policy-${terraform.workspace}"
  description = "Policy for the get_credentials lambda function"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "cognito-identity:GetId",
        "cognito-identity:GetCredentialsForIdentity"
      ],
      Resource = ["arn:aws:cognito-identity:${var.aws_region}:${data.aws_caller_identity.current.account_id}:identitypool/${aws_cognito_identity_pool.ims_identity_pool.id}"]
    }]
  })
}

# Add group to Cognito user (User pools) lambda function policy
resource "aws_iam_policy" "add_to_group_policy" {
  name = "add-to-group-policy-${terraform.workspace}"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "cognito-idp:AdminAddUserToGroup",
        "cognito-idp:AdminRemoveUserFromGroup",
        "cognito-idp:AdminListGroupsForUser",

      ],
      Resource = "arn:aws:cognito-idp:${var.aws_region}:${data.aws_caller_identity.current.account_id}:userpool/${aws_cognito_user_pool.ims_user_pool.id}"
    }]
  })
}

# Cognito User Role
# Source: https://docs.aws.amazon.com/cognito/latest/developerguide/role-based-access-control.html
resource "aws_iam_role" "cognito_user_role" {
  name = "CognitoUserRole-${terraform.workspace}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        "StringEquals" : {
          "cognito-identity.amazonaws.com:aud" : aws_cognito_identity_pool.ims_identity_pool.id
        },
        "ForAnyValue:StringLike" : {
          "cognito-identity.amazonaws.com:amr" : "authenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "user_allow_policy" {
  name = "user-allow-policy-${terraform.workspace}"
  role = aws_iam_role.cognito_user_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["execute-api:Invoke"],
      Resource = ["arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/*"]
    }]
  })
}

resource "aws_iam_role_policy" "user_deny_policy" {
  name = "user-deny-policy-${terraform.workspace}"
  role = aws_iam_role.cognito_user_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Deny",
      Action = ["execute-api:Invoke"],
      Resource = [
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/PUT/items",
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/DELETE/items/*",
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/PUT/stores",
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/DELETE/stores/*",
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/GET/auth_test_admin",
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/POST/users/promote/*",
        "arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/POST/users/demote/*"
      ]
    }]
  })
}

# Cognito Admin Role
resource "aws_iam_role" "cognito_admin_role" {
  name = "CognitoAdminRole-${terraform.workspace}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = {
        Federated = "cognito-identity.amazonaws.com"
      },
      Action = "sts:AssumeRoleWithWebIdentity",
      Condition = {
        "StringEquals" : {
          "cognito-identity.amazonaws.com:aud" : aws_cognito_identity_pool.ims_identity_pool.id
        },
        "ForAnyValue:StringLike" : {
          "cognito-identity.amazonaws.com:amr" : "authenticated"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "admin_allow_policy" {
  name = "admin-allow-policy-${terraform.workspace}"
  role = aws_iam_role.cognito_admin_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = ["execute-api:Invoke"],
      Resource = ["arn:aws:execute-api:${var.aws_region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.ims_api.id}/${aws_api_gateway_stage.ims_api_stage_deployment.stage_name}/*"]
    }]
  })
}