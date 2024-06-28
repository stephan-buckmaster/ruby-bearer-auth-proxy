require 'openssl'
require 'rack/auth/basic'

puts "Read #{__FILE__}"
class HTTPBasicAuthentication

  def initialize(app, basic_auth_hash_file)
    @valid_user_password_hashes = self.class.read_basic_auth_hash_file(basic_auth_hash_file)
    @auth = Rack::Auth::Basic.new(app) do |username, password|
      pwd_hash = Digest::SHA256.hexdigest(password)
      @valid_user_password_hashes.include?("#{username}:#{pwd_hash}")
    end
  end

  # Allow stubbing in tests
  def self.read_basic_auth_hash_file(hash_file)
    IO.readlines(hash_file, chomp:true)
  end

  def call(env)
    env["HTTP_HOST"] = ENV["HTTP_HOST"] if ENV["HTTP_HOST"]
    @auth.call env
  end
end
