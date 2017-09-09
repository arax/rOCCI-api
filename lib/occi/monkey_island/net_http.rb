###############################################################################
## Net::HTTP hack allowing the use of X.509 proxy certificates
###############################################################################
require 'net/http'

# :nodoc:
module Net
  # :nodoc:
  class HTTP
    # These are supported in the underlying C-based implementation, just not
    # exposed in Ruby-native bindings.
    silence_warnings do
      SSL_IVNAMES = SSL_IVNAMES.concat [:@extra_chain_cert]
      SSL_ATTRIBUTES = SSL_ATTRIBUTES.concat [:extra_chain_cert]

      attr_accessor :extra_chain_cert
    end
  end
end
