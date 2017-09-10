module Occi
  module API
    # Contains various utilities shared with the rest of the code. For details, see documentation
    # for the particular utility.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Utils; end
  end
end

Dir[File.join(File.dirname(__FILE__), 'utils', '*.rb')].each { |file| require file.gsub('.rb', '') }
