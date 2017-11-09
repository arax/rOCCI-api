module Occi
  module API
    module Middleware
      # Renders objects into body before sending.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class OcciRequest < ::Faraday::Middleware
        extend Forwardable

        CONTENT_TYPE = 'Content-Type'.freeze
        ACCEPT = 'Accept'.freeze
        TYPE_METHOD_MAP = {
          model: :to_json,
          instances: :to_json,
          categories: :to_json,
          locations: :to_text
        }.freeze
        TYPE_MEDIA_MAP = {
          model: 'application/occi+json'.freeze,
          instances: 'application/occi+json'.freeze,
          categories: 'application/occi+json'.freeze,
          locations: 'text/uri-list'.freeze
        }.freeze

        attr_accessor :type, :options

        # @param app [Proc] callable application
        # @param options [Hash] middleware options
        def initialize(app, options = {})
          super(app)

          @type = options.fetch(:type)
          raise ArgumentError, "Request type #{type} is not supported" unless TYPE_METHOD_MAP.key?(type)

          @options = options
        end

        # @param env [Hash] Faraday request environment
        def call(env)
          if env[:body].present?
            env[:body] = env[:body].send(TYPE_METHOD_MAP[type])
            env[:request_headers][CONTENT_TYPE] = TYPE_MEDIA_MAP[type]
          end

          env[:request_headers][ACCEPT] = TYPE_MEDIA_MAP[type]
          @app.call env
        end
      end
    end
  end
end
