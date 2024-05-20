require 'openssl'

while line = gets do
  token = line.chomp.strip
  puts Digest::SHA256.hexdigest(token)
end
