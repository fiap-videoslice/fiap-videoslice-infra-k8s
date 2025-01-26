#######################################################
## Cognito user pool
#
# Incluído junto à infra básica da aplicação pois é
# pré-requisito para o deploy. Integração com Autenticador (lambda)
# ocorre no workflow de repositório próprio

variable "cognito_domain_name" {
  type = string
  description = "Domain name for the Cognito user pool"
  default = "videoslice-logins"
}

resource "aws_cognito_user_pool" "videoslice-logins" {
  name = "videoslice-logins"

  username_attributes = ["email"]

  password_policy {
    minimum_length = 6
    temporary_password_validity_days = 7
  }

  admin_create_user_config {
    allow_admin_create_user_only = false
  }
}

resource "aws_cognito_user_group" "regular-users" {
  name         = "User"
  user_pool_id = aws_cognito_user_pool.videoslice-logins.id
  description  = "Regular users of the Video Slice tool"
  precedence   = 1
}

resource "aws_cognito_user_group" "admin-users" {
  name         = "Admin"
  user_pool_id = aws_cognito_user_pool.videoslice-logins.id
  description  = "Administrator login. Can create users."
  precedence   = 1
}

resource "aws_cognito_user_pool_client" "app-token-client" {
  name = "app-token-client"

  callback_urls                        = ["http://localhost:8090/auth/response"]
  allowed_oauth_flows                  = ["code"]
  user_pool_id = aws_cognito_user_pool.videoslice-logins.id
  allowed_oauth_scopes                 = ["email", "openid", "phone"]
  supported_identity_providers         = ["COGNITO"]

  generate_secret = true
  refresh_token_validity = 90
  access_token_validity = 2
  prevent_user_existence_errors = "ENABLED"
  explicit_auth_flows = [
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]
}

resource "aws_cognito_user_pool_domain" "cognito-domain" {
  domain       = var.cognito_domain_name
  user_pool_id = aws_cognito_user_pool.videoslice-logins.id
}

output "user-pool-id" {
  value = aws_cognito_user_pool.videoslice-logins.id
}

output "app-token-client-id" {
  value = aws_cognito_user_pool_client.app-token-client.id
}

output "app-token-client-secret" {
  value = aws_cognito_user_pool_client.app-token-client.client_secret
  sensitive = true
}
