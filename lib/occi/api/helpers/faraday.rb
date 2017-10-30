module Occi
  module API
    module Helpers
      # @author Boris Parak <parak@cesnet.cz>
      module Faraday
        # The only currently supported media type
        DEFAULT_CONTENT_TYPE = 'application/occi+json'.freeze

        # :nodoc:
        def make(verb, relative_url, request = {})
          connection_factory(request).send(verb) do |req|
            req.url "#{endpoint}#{relative_url}"
            req.headers['Accept'] = DEFAULT_CONTENT_TYPE
            req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
            req.headers.merge! request.fetch(:headers, {})
            req.body = request[:body] if request[:body]
          end
        end

        # :nodoc:
        def connection_factory(request)
          ::Faraday.new do |faraday|
            connection_middleware faraday, request
            faraday.ssl.merge! options.fetch(:ssl, {})
            faraday.adapter :net_http
          end
        end

        # :nodoc:
        def connection_middleware(faraday, request)
          # Request
          faraday.request :token, credentials
          faraday.request :occi
          # Response
          faraday.response :occi, parser_options: request
          faraday.response :raise_error
          faraday.response :logger, logger
        end
      end
    end
  end
end
