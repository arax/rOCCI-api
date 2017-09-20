require 'faraday_middleware/response_middleware'

module Occi
  module API
    module Middleware
      # @author Boris Parak <parak@cesnet.cz>
      class OcciResponse < ::FaradayMiddleware::ResponseMiddleware
        MIME_TYPES = %w[application/occi+json].freeze

        define_parser do |body, parser_options|
          mime_type = parser_options.fetch(:mime_type)
          raise "Unsupported media type #{mime_type.inspect}" unless MIME_TYPES.include?(mime_type)
          send parser_options.fetch(:type), body, parser_options
        end

        class << self
          # :nodoc:
          def model(_body, _options)
            Occi::InfrastructureExt::Model.new
          end

          # :nodoc:
          def instances(_body, options)
            options.fetch(:model)
            Occi::Core::Collection.new
          end

          # :nodoc:
          def mixins(_body, options)
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
