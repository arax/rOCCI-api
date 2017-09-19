# external deps
require 'active_support/all'
require 'yell'
require 'faraday'
require 'faraday_middleware'
require 'occi/core'

# Contains all OCCI-related classes and modules. This module
# does not provide any additional functionality aside from
# acting as a wrapper and a namespace-defining mechanisms.
# Please, defer to specific classes and modules within this
# namespace for details and functionality descriptions.
#
# @author Boris Parak <parak@cesnet.cz>
module Occi
  # Contains all OCCI-API-related classes and modules. This
  # module does not provide any additional functionality aside
  # from acting as a wrapped, a namespace-defining mechanism,
  # and versioning wrapper. Please, defer to specific classes
  # and modules within this namespace for details and
  # functionality descriptions.
  #
  # @example
  #   Occi::API::VERSION       # => '5.0.0.alpha.1'
  #   Occi::API::MAJOR_VERSION # => 5
  #   Occi::API::MINOR_VERSION # => 0
  #   Occi::API::PATCH_VERSION # => 0
  #   Occi::API::STAGE_VERSION # => 'alpha.1'
  #
  # @author Boris Parak <parak@cesnet.cz>
  module API
    autoload :Errors, 'occi/api/errors'
    autoload :Utils, 'occi/api/utils'
    autoload :Helpers, 'occi/api/helpers'
    autoload :Middleware, 'occi/api/middleware'
    autoload :Auth, 'occi/api/auth'

    autoload :Authenticator, 'occi/api/authenticator'
    autoload :Client, 'occi/api/client'
  end
end

# Explicitly load monkey patches
require 'occi/monkey_island/net_http'
require 'occi/monkey_island/faraday_adapter_net_http'

# Explicitly pull in versioning information
require 'occi/api/version'
