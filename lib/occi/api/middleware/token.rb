module Occi
  module API
    module Middleware
      # Adds `X-Auth-Token` to every outgoing request.
      #
      # @attr token [String] request token
      #
      # @author Boris Parak <parak@cesnet.cz>
      class Token < ::Faraday::Middleware
        extend Forwardable

        AUTH_HEADER = 'X-Auth-Token'.freeze

        attr_accessor :token

        def call(env)
          env[:request_headers][AUTH_HEADER] ||= @token
          @app.call env
        end

        def initialize(app, options = {})
          super(app)
          @token = options.fetch(:token)
          warn 'Warning: Occi::API::Middleware::Token initialized with an empty token' if token.empty?
        end
      end
    end
  end
end
