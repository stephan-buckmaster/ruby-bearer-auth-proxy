require 'openssl'

while line = gets do
  line.chomp.strip =~ /^(.+):(.+)$/
  user = $1
  password = $2
  if user && password
    puts "#{user.strip}:#{Digest::SHA256.hexdigest(password.strip)}"
  else
    $stderr.puts "Invalid input"
  end
end
