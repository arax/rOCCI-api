###############################################################################
## Faraday::Adapter::NetHttp hack allowing the use of X.509 proxy certificates
###############################################################################
require 'faraday/adapter/net_http'

# :nodoc:
module Faraday
  # :nodoc:
  class Adapter
    # :nodoc:
    class NetHttp
      alias original_configure_ssl configure_ssl
      remove_method :configure_ssl

      # :nodoc:
      def configure_ssl(http, ssl)
        original_configure_ssl http, ssl
        return unless ssl.key?(:extra_chain_cert)
        http.extra_chain_cert = ssl[:extra_chain_cert]
      end
    end
  end
end
