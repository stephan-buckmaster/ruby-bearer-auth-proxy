require 'sinatra'
require 'rack/proxy'
require 'rack/rewindable_input'
require './bearer_authentication'

class App < Sinatra::Base
  use Rack::RewindableInput::Middleware
  use BearerAuthentication, ENV['TOKEN_HASH_FILE']
  use Rack::Proxy, backend: ENV['UPSTREAM_URL']

  get '/' do
    @app.call(env)
  end
end
