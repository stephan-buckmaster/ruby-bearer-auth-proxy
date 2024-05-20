require 'openssl'

class BearerAuthentication

  def initialize(app, token_hash_file)
    @valid_token_hashes = IO.readlines(token_hash_file, chomp:true)
    @app = app
  end

  def call(env)
    env['HTTP_AUTHORIZATION'] =~ /Bearer (.*)/
    bearer_token = $1.to_s
    if bearer_token.nil? || bearer_token.empty?
      return [401, {}, ['No bearer token was provided']]
    end

    bearer_token_hash = Digest::SHA256.hexdigest(bearer_token.strip)
    unless @valid_token_hashes.include?(bearer_token_hash)
      return [401, {}, ['Invalid bearer token']]
    end

    env.delete('HTTP_AUTHORIZATION') # unless the upstream wants it too?
    @app.call(env)
  end
end
