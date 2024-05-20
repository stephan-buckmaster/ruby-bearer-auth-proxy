require 'rack/proxy'
require 'rack/rewindable_input'
require './bearer_authentication'

module CreateBearerAuthProxyApp
  def self.create_app(token_hash_file, upstream_url)
    Rack::Builder.app do
      use Rack::RewindableInput::Middleware
      use BearerAuthentication, token_hash_file
      use Rack::Proxy, backend: upstream_url
      run lambda { |env| [200, {'Content-Type' => 'text/plain'}, ['OK']] }
    end
  end
end
