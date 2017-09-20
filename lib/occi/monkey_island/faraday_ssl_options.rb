###############################################################################
## Faraday::SSLOptions hack allowing the use of X.509 proxy certificates
###############################################################################
require 'faraday/options'

# Completely remove the original
Faraday.send(:remove_const, :SSLOptions)

# :nodoc:
module Faraday
  # :nodoc:
  class SSLOptions < Options.new(:verify, :ca_file, :ca_path, :verify_mode, :cert_store, :client_cert, :client_key,
                                 :extra_chain_cert, :certificate, :private_key, :verify_depth, :version)

    def verify?
      verify != false
    end

    def disable?
      !verify?
    end
  end
end
