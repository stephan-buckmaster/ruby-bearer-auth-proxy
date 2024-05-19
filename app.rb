require './proxy'
require 'rack/rewindable_input'
require 'sinatra'

class OurProxy < Rack::Proxy
  def initialize(app)
    @app = Rack::Proxy.new(backend: 'http://localhost:10000')
  end
  def call(env)
    @app.call(env)
  end
end
class App < Sinatra::Base
  use Rack::RewindableInput::Middleware
  use BearerAuthentication
  use OurProxy

  get '/' do
    @app.call(env)
  end
end
