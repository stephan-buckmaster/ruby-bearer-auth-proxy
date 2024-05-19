require './proxy'
require 'rack/rewindable_input'
require 'sinatra'

class App < Sinatra::Base
  use Rack::RewindableInput::Middleware
  use BearerAuthentication, 'valid-token'
  use Rack::Proxy, backend: 'http://localhost:10000'

  get '/' do
    @app.call(env)
  end
end
