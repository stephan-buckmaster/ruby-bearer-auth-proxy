require 'rack/proxy'
require 'rack/rewindable_input'

class BearerAuthentication < Rack::Proxy


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
