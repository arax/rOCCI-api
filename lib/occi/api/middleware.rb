module Occi
  module API
    # Wrapper for all custom Faraday middleware.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Middleware
      autoload :Token, 'occi/api/middleware/token'
      autoload :OcciResponse, 'occi/api/middleware/occi_response'
      autoload :OcciRequest, 'occi/api/middleware/occi_request'
    end
  end
end
