module Occi
  module API
    module Middleware
      # Renders objects into body before sending.
      #
      # @author Boris Parak <parak@cesnet.cz>
      class OcciRequest < ::Faraday::Middleware
        extend Forwardable

        def call(env)
          # Render stuff
          @app.call env
        end
      end
    end
  end
end
