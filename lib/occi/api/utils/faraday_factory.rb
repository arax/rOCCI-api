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
            faraday.use :instrumentation
            faraday.adapter :net_http
          end
        end

        # :nodoc:
        def add_middleware!(faraday, request_options)
          # Request middleware
          faraday.request :token, credentials
          faraday.request :occi, request_options
          # Response middleware
          faraday.response :occi, request_options
          faraday.response :raise_error
          faraday.response :logger, logger
        end

        class << self
          # :nodoc:
          def profile!
            ActiveSupport::Notifications.subscribe('request.faraday') do |name, starts, ends, _, env|
              url = env[:url]
              http_method = env[:method].to_s.upcase
              duration = ends - starts
              logger.info { "Request - [%s] %s %s (%.3f s)" % [url.host, http_method, url.request_uri, duration] }
            end
          end
        end
      end
    end
  end
end
