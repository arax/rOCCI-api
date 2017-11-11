module Occi
  module API
    # Wrapper for all custom error classes. For details on intended
    # use, see specific error classes within this module.
    module Errors; end
  end
end

Dir[File.join(__dir__, 'errors', '*.rb')].each { |file| require file.gsub('.rb', '') }
