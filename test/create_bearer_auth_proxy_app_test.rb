require 'stub_server'
require "test/unit"
require "rack/test"
require "rackup/handler/webrick"
require './create_bearer_auth_proxy_app'

class CreateBearerAuthProxyAppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    CreateBearerAuthProxyApp.create_app('test/test_token_hashes', 'http://localhost:123456') # We are starting a test server below
  end

  def test_get_no_authorization
    get '/'
    assert_equal 401, last_response.status
    assert_equal 'No bearer token was provided', last_response.body
  end

  def test_get_invalid_token
    get '/', nil, {'HTTP_AUTHORIZATION' => 'Bearer not-abcdef'}
    assert_equal 401, last_response.status
    assert_equal 'Invalid bearer token',  last_response.body
  end

  def test_get_valid_token
    StubServer.open(123456, {"/" => [200, {}, ["Hello World of Testers"]] }) do |server|
      server.wait
      get '/', nil, {'HTTP_AUTHORIZATION' => 'Bearer abcdef'}
    end
    assert_equal 200, last_response.status
    assert_equal "Hello World of Testers", last_response.body
  end

  def test_get_valid_token_from_several
    StubServer.open(123456, {"/" => [200, {}, ["Hello World of Testers"]] }) do |server|
      server.wait
      get '/', nil, {'HTTP_AUTHORIZATION' => 'Bearer abcdefghi'}
    end
    assert_equal 200, last_response.status
    assert_equal "Hello World of Testers", last_response.body
  end

end
