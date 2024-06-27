require 'openssl'

class BearerAuthentication

  def initialize(app, token_hash_file)
    @valid_token_hashes = self.class.read_token_hash_file(token_hash_file)
    @app = app
  end

  # Allow stubbing in tests
  def self.read_token_hash_file(token_hash_file)
    IO.readlines(token_hash_file, chomp:true)
  end

  def call(env)
    env['HTTP_AUTHORIZATION'] =~ /Bearer (.*)/
    bearer_token = $1.to_s
    if bearer_token.nil? || bearer_token.empty?
      return [401, {}, ["No bearer token was provided"]]
    end

    bearer_token_hash = Digest::SHA256.hexdigest(bearer_token.strip)
    unless @valid_token_hashes.include?(bearer_token_hash)
      return [401, {}, ["Invalid bearer token"]]
    end

    env["HTTP_HOST"] = ENV["HTTP_HOST"] if ENV["HTTP_HOST"]

    env.delete("HTTP_AUTHORIZATION") # don't pass on the secret token
    @app.call(env)
  end
end
