ENV['UPSTREAM_URL'] = 'http://localhost:123456' # We are starting a test server below

require 'stub_server'
require "test/unit"
require "rack/test"
require "rackup/handler/webrick"

require_relative File.dirname(__FILE__) + '/../../app.rb'

class AppTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    App.new
  end

  def test_get_no_authorization
    get '/'
    assert_equal 401, last_response.status
    assert_equal 'No bearer token was provided', last_response.body
  end

  def test_get_invalid_token
    stub_valid_tokens('abcdef')
    get '/', nil, {'HTTP_AUTHORIZATION' => 'Bearer not-abcdef'}
    assert_equal 401, last_response.status
    assert_equal 'Invalid bearer token',  last_response.body
  end

  def test_get_valid_token
    stub_valid_tokens('abcdef')
    StubServer.open(123456, {"/" => [200, {}, ["Hello World of Testers"]] }) do |server|
      server.wait
      get '/', nil, {'HTTP_AUTHORIZATION' => 'Bearer abcdef'}
    end
    assert_equal 200, last_response.status
    assert_equal "Hello World of Testers", last_response.body
  end

  def test_get_valid_token_from_several
    stub_valid_tokens('abcdefghi', 'abcdefg')
    StubServer.open(123456, {"/" => [200, {}, ["Hello World of Testers"]] }) do |server|
      server.wait
      get '/', nil, {'HTTP_AUTHORIZATION' => 'Bearer abcdefghi'}
    end
    assert_equal 200, last_response.status
    assert_equal "Hello World of Testers", last_response.body
  end

  private

  def stub_valid_tokens(*valid_tokens)
    hashes = valid_tokens.map { |x| Digest::SHA256.hexdigest(x)}
    BearerAuthentication.instance_eval("def read_token_hash_file(ignored); return #{hashes.inspect}; end")
  end
end
