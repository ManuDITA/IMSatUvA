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

# Configure the Cognito User Groups
resource "aws_cognito_user_group" "ims_user_group" {
  user_pool_id = aws_cognito_user_pool.ims_user_pool.id
  name         = "Users"
}

resource "aws_cognito_user_group" "ims_admin_group" {
  user_pool_id = aws_cognito_user_pool.ims_user_pool.id
  name         = "Admins"
}