# Configure AWS Cognito User Pool
resource "aws_cognito_user_pool" "ims_user_pool" {
  name = "ims-user-pool"
}

# Configure the domain for the Cognito User Pool
resource "aws_cognito_user_pool_domain" "ims_cognito_domain" {
  domain       = "ims-signin"
  user_pool_id = aws_cognito_user_pool.ims_user_pool.id
}

# Configure the client for the Cognito User Pool
resource "aws_cognito_user_pool_client" "ims_cognito_client" {
  name                                 = "ims-cognito-client"
  user_pool_id                         = aws_cognito_user_pool.ims_user_pool.id
  callback_urls                        = ["https://oauth.pstmn.io/v1/browser-callback"]
  allowed_oauth_flows_user_pool_client = true
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid", "profile"]
  supported_identity_providers         = ["COGNITO"]
}

# Configure Cognito client style
resource "aws_cognito_user_pool_ui_customization" "ims_user_pool_ui" {
  css          = ".label-customizable {font-weight: 400;}"
  user_pool_id = aws_cognito_user_pool_domain.ims_cognito_domain.user_pool_id
  client_id    = aws_cognito_user_pool_client.ims_cognito_client.id
}

# Configure the Cognito User Groups
resource "aws_cognito_user_group" "ims_user_group" {
  user_pool_id = aws_cognito_user_pool.ims_user_pool.id
  name         = "Users"
  role_arn     = aws_iam_role.cognito_user_role.arn
}

resource "aws_cognito_user_group" "ims_admin_group" {
  user_pool_id = aws_cognito_user_pool.ims_user_pool.id
  name         = "Admins"
  role_arn     = aws_iam_role.cognito_admin_role.arn
}

resource "aws_cognito_identity_pool" "ims_identity_pool" {
  identity_pool_name               = "ims_identity_pool"
  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.ims_cognito_client.id
    provider_name           = aws_cognito_user_pool.ims_user_pool.endpoint
    server_side_token_check = true
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "ims_identity_pool_roles" {
  identity_pool_id = aws_cognito_identity_pool.ims_identity_pool.id

  roles = {
    authenticated = aws_iam_role.cognito_user_role.arn
  }

  role_mapping {
    identity_provider         = "${aws_cognito_user_pool.ims_user_pool.endpoint}:${aws_cognito_user_pool_client.ims_cognito_client.id}"
    ambiguous_role_resolution = "AuthenticatedRole"
    type                      = "Rules"

    mapping_rule {
      claim      = "cognito:groups"
      match_type = "Contains"
      value      = aws_cognito_user_group.ims_admin_group.name
      role_arn   = aws_iam_role.cognito_admin_role.arn
    }
  }
}