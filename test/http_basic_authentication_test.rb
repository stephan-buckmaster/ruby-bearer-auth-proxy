require "test/unit"
require "base64"
require "./http_basic_authentication"

class TestApp
  def call(env)
    [200, env, "TestApp called"]
  end
end

class HTTPBasicAuthenticationTest < Test::Unit::TestCase

  # The test_token_hashes include the hash of abcdef
  def setup
    @test_object = HTTPBasicAuthentication.new(TestApp.new, File.dirname(__FILE__) + "/test_user_pwd_hashes")
  end

  def authentication_header(user,password)
    {"Authorization" =>  "Basic " + Base64::encode64("#{user}:#{password}")}
  end

  def test_validates_authorization_none_given
    headers = {}
    assert_equal [401, {"content-length"=>"0", "content-type"=>"text/plain", "www-authenticate"=>"Basic realm=\"\""}, []], @test_object.call(headers)
  end

  def test_validates_authorization_invalid_given
    headers = authentication_header("none","wrong")
    assert_equal [401, {"content-length"=>"0", "content-type"=>"text/plain", "www-authenticate"=>"Basic realm=\"\""}, []], @test_object.call(headers)
  end

  def test_validates_authorization_valid
    headers = authentication_header("testinguser", "test-password-123")
    assert_equal [401, {"content-length"=>"0", "content-type"=>"text/plain", "www-authenticate"=>"Basic realm=\"\""}, []], @test_object.call(headers)
  end

end
