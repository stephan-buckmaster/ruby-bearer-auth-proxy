require 'rack/proxy'
require 'rack/rewindable_input'
require './http_basic_authentication'

module CreateHTTPBasicAuthProxyApp
  def self.create_app(basic_auth_hash_file, upstream_url)
    Rack::Builder.app do
      use Rack::RewindableInput::Middleware
      use HTTPBasicAuthentication, basic_auth_hash_file
      use Rack::Proxy, backend: upstream_url
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    end
  end
end
