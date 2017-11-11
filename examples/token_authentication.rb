require 'occi/api'

Yell.new STDERR, name: Object

authr = Occi::API::Authenticator.new(type: :token) do |opts|
  opts[:credentials] = { token: 'THIS_IS_MY_RAW_TOKEN' }
end

# `token!` and `scopes` raise Occi::API::Errors::AuthenticationError on failure
unscoped = authr.token!
puts "Unscoped token: #{unscoped}"

# Direct/raw token authentication does not support scopes, empty list will be returned
scopes = authr.scopes(unscoped)
puts "Available scopes: #{scopes}"

# Direct/raw token authentication does not support scopes, the same token will be returned
puts "Scoped token: #{authr.token!}"
