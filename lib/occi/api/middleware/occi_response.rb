module Occi
  module API
    module Middleware
      # @author Boris Parak <parak@cesnet.cz>
      class OcciResponse < ::Faraday::Middleware
        CONTENT_TYPE = 'Content-Type'.freeze
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
          raise ArgumentError, "Response type #{type} is not supported" unless TYPE_MEDIA_MAP.key?(type)

          @options = options
        end

        def call(environment)
          @app.call(environment).on_complete do |env|
            env[:raw_body] = env[:body]
            env[:body] = send(type, env[:body], env[:response_headers])
          end
        end

        private

        # :nodoc:
        def model(body, headers)
          new_model = Occi::InfrastructureExt::Model.new
          Occi::Core::Parsers::JsonParser.model(body, headers, TYPE_MEDIA_MAP[type], new_model)
          new_model.valid!
          new_model
        end

        # :nodoc:
        def instances(body, headers)
          collection = Occi::Core::Collection.new(
            categories: options.fetch(:model).categories,
            entities: parser.entities(body, headers, options.fetch(:expectation, nil))
          )
          collection.valid!
          collection
        end

        # :nodoc:
        def categories(body, headers)
          parser.categories(body, headers, options.fetch(:expectation, nil))
        end

        # :nodoc:
        def locations(body, headers)
          uris = Occi::Core::Parsers::TextParser.locations(body, headers, TYPE_MEDIA_MAP[type])
          locations = Occi::Core::Locations.new(uris: Set.new(uris))
          locations.valid!
          locations
        end

        # :nodoc:
        def parser
          Occi::Core::Parsers::JsonParser.new(model: options.fetch(:model), media_type: TYPE_MEDIA_MAP[type])
        end
      end
    end
  end
end
