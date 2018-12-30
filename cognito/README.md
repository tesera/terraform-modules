# Cognito
This is a template only for configuring Cognito User Pool, Cognito User Pool Client and Cognito User Identity Providers.
Due to limitation of the current version of terraform and circular dependencies, this can not be defined as terraform module at this point.
Recommended way for setting up cognito and api gateway - https://serverless-stack.com

The first step is to create the user pool with the user pool client.
```hcl-terraform

resource "aws_cognito_user_pool" "main" {
  name                = "${local.name}-pool"
  username_attributes = ["email"]

  verification_message_template {
    default_email_option = "CONFIRM_WITH_CODE"
  }

  auto_verified_attributes = ["email"]

  email_configuration {
    reply_to_email_address = "someone@company.com"
  }

  password_policy {
    minimum_length    = 10
    require_lowercase = false
    require_numbers   = true
    require_symbols   = false
    require_uppercase = true
  }

  tags = "${merge(local.tags, map(
    "Name", "${local.name}-user-pool",
    "Project", "Terraform"
  ))}"
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "kiril-test"
  user_pool_id = "${aws_cognito_user_pool.main.id}"
}

resource "aws_cognito_user_pool_client" "client" {
  name = "${local.name}-client"
  callback_urls        = ["callback_url1", "callback_url2"]
  default_redirect_uri = "redirect_uri"
  logout_urls          = ["logout_url1", "logout_url2"]
  allowed_oauth_flows_user_pool_client = "true"
  user_pool_id                 = "${aws_cognito_user_pool.main.id}"
  supported_identity_providers = ["COGNITO"]
  # supported_identity_providers = ["COGNITO", "Facebook", "Auth0", "Google"]
  allowed_oauth_flows          = ["implicit"]
  allowed_oauth_scopes         = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
}

```
Note that the second line for supported_identity_providers is commented out. This needs to be uncommented and after the identity providers are configured and execute terraform apply again.

To add Social identity providers we need to configure them before we can add them to the user pool. 
For Facebook configuration follow the steps for "To register an app with Facebook" - https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-social-idp.html
After the app is registered the following template can be filled with the actual client_id and client_secret_id and execute
terraform apply to create the Facebook idp.
```hcl-terraform
resource "aws_cognito_identity_provider" "facebook" {
  user_pool_id  = "${aws_cognito_user_pool.main.id}"
  provider_name = "Facebook"
  provider_type = "Facebook"

  provider_details {
    authorize_scopes = "public_profile,email"
    client_id        = "122556421922030"
    client_secret    = "c1a18abaf23897228f27211910562cf4"
    attributes_url                = "https://graph.facebook.com/me?fields="
    attributes_url_add_attributes = "true"
    authorize_url                 = "https://www.facebook.com/v2.9/dialog/oauth"
    token_request_method          = "GET"
    token_url                     = "https://graph.facebook.com/v2.9/oauth/access_token"
  }

  attribute_mapping {
    username = "id"
  }
}
```

For Google configuration follow the steps for "To register an app with Google" - https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-social-idp.html
After the app is registered the following template can be filled with the actual client_id and client_secret_id and execute
terraform apply to create the Google idp.
```hcl-terraform
resource "aws_cognito_identity_provider" "google" {
  user_pool_id  = "${aws_cognito_user_pool.main.id}"
  provider_name = "Google"
  provider_type = "Google"

  provider_details {
    authorize_scopes = "profile email openid"
    client_id        = "672811282909-mhm6fi1av04jmrlo62tuabt8ll0k7cn4.apps.googleusercontent.com"
    client_secret    = "lx-5cCN5zCjll4tfJt2cPv_G"
    attributes_url                = "https://people.googleapis.com/v1/people/me?personFields="
    attributes_url_add_attributes = "true"
    authorize_url                 = "https://accounts.google.com/o/oauth2/v2/auth"
    oidc_issuer                   = "https://accounts.google.com"
    token_request_method          = "POST"
    token_url                     = "https://www.googleapis.com/oauth2/v4/token"
  }

  attribute_mapping {
    username = "sub"
  }
}
```

For adding OpenID Connect (OIDC) identity providers follow these steps:
https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-oidc-idp.html

For example of using Auth0 as OIDC idp, create new app in Auth0 and configure the following fields:
Domain - hris-viewer.auth0.com
Token Endpoint Authentication Method - Post
Allowed Callback URLs - https://<your-user-pool-domain>/oauth2/idpresponse
Allowed Web Origins - https://<your-user-pool-domain>/
Allowed Origins (CORS) - https://<your-user-pool-domain>/

After creating the app in Auth0, the following terraform template can be used to create the OIDC provider in Cognito, by replacing the actual values.

```hcl-terraform
resource "aws_cognito_identity_provider" "oidc" {
  user_pool_id  = "${aws_cognito_user_pool.main.id}"
  provider_name = "Auth0"
  provider_type = "OIDC"

  provider_details {
    authorize_scopes              = "openid email profile"
    client_id                     = "ksZJnlLazxGfdhznm8R06wD5du96mmqN"
    client_secret                 = "YI82SZ2Qq_ZfTCrN5X685JSCFp5cjMrfODoX1mAfFURFWwHRFrxuEu4QNVYYNZIz"
    attributes_request_method     = "POST"
    attributes_url                = "https://hris-viewer.auth0.com/userinfo"
    attributes_url_add_attributes = "false"
    authorize_url                 = "https://hris-viewer.auth0.com/authorize"
    jwks_uri                      = "https://hris-viewer.auth0.com/.well-known/jwks.json"
    oidc_issuer                   = "https://hris-viewer.auth0.com"
    token_url                     = "https://hris-viewer.auth0.com/oauth/token"
  }

  attribute_mapping {
    username = "sub"
  }
}
```

At this point you should be able to test the Cognito web ui with all idp that are configured (including Cognito).
The UI can be accessed at:
https://<your-user-pool-domain>/login?response_type=token&client_id=<client-id-found-in-the-console>&redirect_uri=<redirect-url>

After the user pool is created and configured, if we want to attach the user pool to API gateway this can be accomplished by adding this to the api gateway:
```hcl-terraform
resource "aws_api_gateway_authorizer" "cognito" {
  name          = "cognito-authorizer"
  type          = "COGNITO_USER_POOLS"
  rest_api_id   = "${aws_api_gateway_rest_api.kiril_api.id}"
  provider_arns = ["${aws_cognito_user_pool.main.arn}"]
}
```

And the cognito authorizer need to be added to the api gateway methods that need it:

```hcl-terraform
resource "aws_api_gateway_method" "get" {
  rest_api_id = "${aws_api_gateway_rest_api.kiril_api.id}"
  resource_id = "${aws_api_gateway_resource.demo.id}"
  http_method = "GET"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = "${aws_api_gateway_authorizer.cognito.id}"
}
```

```hcl-terraform
resource "aws_cognito_identity_pool" "main" {
  identity_pool_name               = "IdentityPool"
  allow_unauthenticated_identities = true

  cognito_identity_providers {
    client_id               = "4bvmqmvc878gucnvaca0h5m29n"
    provider_name           = "cognito-idp.us-west-2.amazonaws.com/us-west-2_C4Hlmj3zz"
    server_side_token_check = false
  }

  supported_login_providers {
    "graph.facebook.com"  = "122556421965030"
    "accounts.google.com" = "1234672811282909-mhm6fi1av04jmrlo62tuabt8j70k7cn456789012.apps.googleusercontent.com"
  }

  #saml_provider_arns           = ["${aws_iam_saml_provider.default.arn}"]
  #openid_connect_provider_arns = ["${aws_cognito_identity_provider.oidc.arn}"]
}
```

To fully utilize cognito in real world application the callback_urls should be pointing to web application that is going to receive the JWT and then forward it to the API Gateway through the Authorization header.
