require './create_bearer_auth_proxy_app'

App = CreateBearerAuthProxyApp.create_app(ENV['TOKEN_HASH_FILE'], ENV['UPSTREAM_URL'])
