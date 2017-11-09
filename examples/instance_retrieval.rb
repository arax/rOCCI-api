require 'occi/api'

Yell.new STDERR, name: Object

## Get Model ##

mc = Occi::API::Clients::Model.new(
  endpoint: 'https://localhost:3000/',     # OCCI endpoint
  credentials: 'am9obm55Om9wZW5uZWJ1bGEK', # Scoped token from Occi::API::Authenticator
  options: { ssl: { verify: false } }      # This is INSECURE!
)

mc.model

## Now - Compute Instances ##

client = Occi::API::Clients::Instances.new(
  endpoint: 'https://localhost:3000/',     # OCCI endpoint
  credentials: 'am9obm55Om9wZW5uZWJ1bGEK', # Scoped token from Occi::API::Authenticator
  model: mc.model,                         # Model from the corresponding OCCI endpoint
  options: { ssl: { verify: false } }      # This is INSECURE!
)

compute_kind = mc.model.find_by_identifier!(Occi::Infrastructure::Constants::COMPUTE_KIND)
puts 'Instances:'
client.describe(compute_kind).resources.each do |compute|
  puts "* #{compute.title} - #{compute.location} (IP: #{compute.networkinterfaces.first.attributes['occi.networkinterface.address']})"
end
