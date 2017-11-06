module Occi
  module API
    module Middleware
      # @author Boris Parak <parak@cesnet.cz>
      class OcciResponse < ::Faraday::Middleware
        # Supported request formats
        SUPPORTED_FORMATS = {
          json: 'applications/occi+json'.freeze,
          uri_list: 'text/uri-list'.freeze
        }.freeze

        def call(env)
          # Parse stuff
          @app.call env
        end

        class << self
          # :nodoc:
          def model(body, _options)
            m = Occi::InfrastructureExt::Model.new
            Occi::Core::Parsers::JsonParser.model(body, {}, SUPPORTED_FORMATS.fetch(:json), m)
            m.valid!
            m
          end

          # :nodoc:
          def instances(_body, options)
            options.fetch(:model)
            Occi::Core::Collection.new
          end

          # :nodoc:
          def categories(_body, options)
            options.fetch(:model)
            Set.new
          end

          # :nodoc:
          def locations(_body, _options)
            Occi::Core::Locations.new
          end
        end
      end
    end
  end
end
