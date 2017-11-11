require 'occi/api'

Yell.new STDERR, name: Object

authr = Occi::API::Authenticator.new(type: :keystone) do |opts|
  opts[:type] = :oauth2
  opts[:endpoint] = 'https://localhost:5000/'
  opts[:credentials] = { token: 'THIS_IS_MY_ACCESS_TOKEN', identity_provider: 'egi.eu' }
end

# `token!` and `scopes` raise Occi::API::Errors::AuthenticationError on failure
unscoped = authr.token!
puts "Unscoped token: #{unscoped}"

scopes = authr.scopes(unscoped)
puts "Available scopes: #{scopes}"

puts "Scoped token for #{scopes.first[:name]}: #{authr.token!(scopes.first[:id], unscoped)}"
