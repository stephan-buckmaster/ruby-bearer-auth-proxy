require './create_http_basic_auth_proxy_app'

HttpBasicAuthApp = CreateHTTPBasicAuthProxyApp.create_app(ENV['HTTP_BASIC_AUTH_HASH_FILE'], ENV['UPSTREAM_URL'])
