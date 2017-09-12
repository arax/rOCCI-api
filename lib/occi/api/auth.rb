module Occi
  module API
    # Contains authentication plugins shared with the rest of the code. For details, see documentation
    # for the particular plugin.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Auth; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'auth', '*.rb')].each { |file| require file.gsub('.rb', '') }
