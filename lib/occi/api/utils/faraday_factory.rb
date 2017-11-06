module Occi
  module API
    module Utils
      # Creates pre-configured Faraday instances. Including required middleware.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class FaradayFactory
        include Yell::Loggable

        attr_accessor :credentials, :options

        def initialize(args = {})
          @credentials = args.fetch(:credentials)
          @options = args.fetch(:options, {})
        end

        # :nodoc:
        def connection(request_options)
          ::Faraday.new do |faraday|
            add_middleware! faraday, request_options
            faraday.ssl.merge! options.fetch(:ssl, {})
            faraday.adapter :net_http
          end
        end

        # :nodoc:
        def add_middleware!(faraday, request_options)
          # Request middleware
          faraday.request :token, credentials
          faraday.request :occi
          # Response middleware
          faraday.response :occi, request_options
          faraday.response :raise_error
          faraday.response :logger, logger
        end
      end
    end
  end
end
