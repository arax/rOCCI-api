module Occi
  module API
    # Wrapper for all custom Faraday middleware.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Middleware
      autoload :Keystone, 'occi/api/middleware/keystone'
      autoload :Token, 'occi/api/middleware/token'
      autoload :OcciModelParser, 'occi/api/middleware/occi_model_parser'
      autoload :OcciInstanceParser, 'occi/api/middleware/occi_instance_parser'
      autoload :OcciMixinParser, 'occi/api/middleware/occi_mixin_parser'

      Faraday::Response.register_middleware \
        keystone: -> { Keystone },
        token: -> { Token },
        occi_model_parser: -> { OcciModelParser },
        occi_instance_parser: -> { OcciInstanceParser },
        occi_mixin_parser: -> { OcciMixinParser }
    end
  end
end
