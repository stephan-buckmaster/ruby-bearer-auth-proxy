require "test/unit"
require "./bearer_authentication"

class TestApp
  def call(env)
    [200, env, "TestApp called"]
  end
end

class BearerAuthenticationTest < Test::Unit::TestCase

  # The test_token_hashes include the hash of abcdef
  def setup
    @test_object = BearerAuthentication.new(TestApp.new, File.dirname(__FILE__) + "/test_token_hashes")
  end

  def test_validates_authorization_none_given
    headers = {}
    assert_equal [401, {}, ["No bearer token was provided"]], @test_object.call(headers)
  end

  def test_validates_authorization_invalid_given
    headers = {"HTTP_AUTHORIZATION" => "Bearer invalid-testing-token"}
    assert_equal [401, {}, ["Invalid bearer token"]], @test_object.call(headers)
  end

  def test_validates_authorization_no_Bearer
    headers = {"HTTP_AUTHORIZATION" => "invalid-testing-token"}
    assert_equal [401, {}, ["No bearer token was provided"]], @test_object.call(headers)
  end

  def test_validates_authorization_valid_given
    headers = {"HTTP_AUTHORIZATION" => "Bearer abcdef"}
    assert_equal [200, {}, "TestApp called"], @test_object.call(headers)
  end

  def test_validates_authorization_passes_on_ENV_except_Authorization
    headers = {"HTTP_AUTHORIZATION" => "Bearer abcdef", "other-header" => "other-value"}
    assert_equal [200, {"other-header" => "other-value"}, "TestApp called"], @test_object.call(headers)
  end

  def test_passes_on_ENV_HTTP_HOST_if_configured
    headers = {"HTTP_AUTHORIZATION" => "Bearer abcdef", "other-header" => "other-value", "HTTP_HOST" => "abcdef.com"}
    orig_env = ENV['HTTP_HOST']
    begin
      ENV['HTTP_HOST'] = "test-replac.com"
      assert_equal [200, {"other-header"=>"other-value", "HTTP_HOST"=>"test-replac.com"}, "TestApp called"], @test_object.call(headers)
    ensure
      ENV['HTTP_HOST'] = orig_env
    end
  end

  def test_leaves_ENV_HTTP_HOST_if_not_configured
    headers = {"HTTP_AUTHORIZATION" => "Bearer abcdef", "other-header" => "other-value", "HTTP_HOST" => "abcdef.com"}
    assert_equal [200, {"other-header"=>"other-value", "HTTP_HOST"=>"abcdef.com"}, "TestApp called"], @test_object.call(headers)
  end
end
