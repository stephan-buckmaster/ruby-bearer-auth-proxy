require 'rack/proxy'
require 'rack/rewindable_input'
#require 'rack/auth/bearer'


class Proxy < Rack::Proxy

  def initialize(app)
    @app = Rack::RewindableInput::Middleware.new(Rack::Proxy.new(backend: 'http://localhost:10000'))
  end

  def call(env)
    # Authenticate the request using Bearer Authentication
    bearer_token = env['HTTP_AUTHORIZATION']
    if bearer_token.nil? || bearer_token.empty?
      return [401, {}, ['No bearer token was provided']]
    end

    unless (bearer_token == 'Bearer valid-token') # Wow we are really doing a simple compare
      return [401, {}, ['Invalid bearer token']]
    end

    env.delete('HTTP_AUTHORIZATION') # unless the upstream wants it too?
    @app.call(env)
  end
end
