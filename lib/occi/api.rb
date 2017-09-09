# external deps
require 'active_support/all'
require 'yell'
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
  module API; end
end

# Explicitly pull in versioning information
require 'occi/api/version'
