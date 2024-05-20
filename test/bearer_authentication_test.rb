require "test/unit"
require_relative File.dirname(__FILE__) + "/../../bearer_authentication.rb"

class TestApp
  def call(env)
    [200, env, "TestApp called"]
  end
end

class BearerAuthenticationTest < Test::Unit::TestCase

  # The test_token_hashes are those of test-token-1 and test-token-2
  def setup
    @test_object = BearerAuthentication.new(TestApp.new, "test/test_token_hashes")
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

  def test_validates_authorization_valid_given_1
    headers = {"HTTP_AUTHORIZATION" => "Bearer testing-token-1"}
    assert_equal [200, {}, "TestApp called"], @test_object.call(headers)
  end

  def test_validates_authorization_valid_given_2
    headers = {"HTTP_AUTHORIZATION" => "Bearer testing-token-2"}
    assert_equal [200, {}, "TestApp called"], @test_object.call(headers)
  end

  def test_validates_authorization_passes_on_ENV_except_Authorization
    headers = {"HTTP_AUTHORIZATION" => "Bearer testing-token-1", "other-header" => "other-value"}
    assert_equal [200, {"other-header" => "other-value"}, "TestApp called"], @test_object.call(headers)
  end

end
