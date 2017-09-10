require 'faraday_middleware/response_middleware'

module Occi
  module API
    module Middleware
      #
      #
      # @author Boris Parak <parak@cesnet.cz>
      class OcciInstanceParser < ::FaradayMiddleware::ResponseMiddleware
        MIME_TYPE = 'application/occi+json'.freeze

        define_parser do |body, parser_options|
          # TODO: use parser
        end
      end
    end
  end
end
