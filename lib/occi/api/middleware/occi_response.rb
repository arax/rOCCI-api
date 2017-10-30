require 'faraday_middleware/response_middleware'

module Occi
  module API
    module Middleware
      # @author Boris Parak <parak@cesnet.cz>
      class OcciResponse < ::FaradayMiddleware::ResponseMiddleware
        MIME_TYPE = 'application/occi+json'.freeze

        define_parser do |body, parser_options|
          send parser_options.fetch(:type), body, parser_options
        end

        class << self
          # :nodoc:
          def model(body, _options)
            m = Occi::InfrastructureExt::Model.new
            Occi::Core::Parsers::JsonParser.model(body, {}, MIME_TYPE, m)
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
