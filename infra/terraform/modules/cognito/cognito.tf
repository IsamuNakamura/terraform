resource "aws_cognito_user_pool" "this" {
  name = var.label

  deletion_protection = "ACTIVE"

  # サインインの設定
  username_configuration {
    # ユーザー名(Email)で大文字小文字を区別しない。
    case_sensitive = false
  }
  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_uppercase                = true
    require_numbers                  = true
    require_symbols                  = true
    temporary_password_validity_days = 7 # 初期登録時の一時的なパスワードの有効期限
  }

  mfa_configuration = "OFF"

  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_email"
      priority = 1
    }
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 2
    }
  }

  # サインアップの設定
  # ユーザー確認のためにメールを自動送信
  auto_verified_attributes = [
    "email",
  ]

  schema {
    attribute_data_type = "String"
    name                = "email"
    required            = true
  }

  admin_create_user_config {
    # ユーザーに自己サインアップを許可
    allow_admin_create_user_only = false

    invite_message_template {
      email_subject = " Your temporary password"
      email_message = " Your username is {username} and temporary password is {####}."
      sms_message   = " Your username is {username} and temporary password is {####}."
    }
  }

  # メッセージングの設定
  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
    email_subject        = " Your verification code"
    email_message        = " Your verification code is {####}."
    sms_message          = " Your verification code is {####}."
  }

  lambda_config {
    custom_message = aws_lambda_function.custom_message.arn
  }

  lifecycle {
    ignore_changes = [
      schema
    ]
  }

  tags = merge(
    var.tags,
    {
      Tier = var.tier,
    }
  )
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.label
  user_pool_id = aws_cognito_user_pool.this.id
}

resource "aws_cognito_user_pool_client" "frontend" {
  name         = "${var.label}-frontend"
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = false
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  auth_session_validity         = 3
  refresh_token_validity        = 30
  access_token_validity         = 1
  id_token_validity             = 1
  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"
}

resource "aws_cognito_user_pool_client" "backend" {
  name         = var.label
  user_pool_id = aws_cognito_user_pool.this.id

  generate_secret = true
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_CUSTOM_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
  ]
  auth_session_validity         = 3
  refresh_token_validity        = 30
  access_token_validity         = 1
  id_token_validity             = 1
  enable_token_revocation       = true
  prevent_user_existence_errors = "ENABLED"

  callback_urls = [
    "https://${var.frontend_domain_name}",
    "https://${var.frontend_domain_name}/",
  ]
  logout_urls = [
    "https://${var.frontend_domain_name}",
    "https://${var.frontend_domain_name}/",
  ]
  supported_identity_providers = [
    "Google"
  ]
  allowed_oauth_flows                  = ["code"]
  allowed_oauth_scopes                 = ["email", "openid"]
  allowed_oauth_flows_user_pool_client = true

  depends_on = [
    aws_cognito_identity_provider.google
  ]
}

resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = aws_cognito_user_pool.this.id
  provider_name = "Google"
  provider_type = "Google"

  provider_details = {
    authorize_scopes = "email"
    client_id        = var.google_client_id
    client_secret    = var.google_client_secret
  }

  attribute_mapping = {
    email    = "email"
    username = "sub"
  }

  lifecycle {
    ignore_changes = [
      provider_details
    ]
  }
}
