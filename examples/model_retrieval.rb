require 'occi/api'

Yell.new STDERR, name: Object

client = Occi::API::Clients::Model.new(
  endpoint: 'https://localhost:3000/',     # OCCI endpoint
  credentials: 'am9obm55Om9wZW5uZWJ1bGEK', # Scoped token from Occi::API::Authenticator
  options: { ssl: { verify: false } }      # This is INSECURE!
)

client.model # Force immediate model retrieval

%i[kinds actions mixins].each do |cat|
  puts "Model #{cat}: #{client.send(cat).map(&:identifier)}"
end
