# app.rb
require './proxy'
require 'sinatra'

class App < Sinatra::Base
  use Proxy

  get '/' do
    @app.call(env)
  end
end
