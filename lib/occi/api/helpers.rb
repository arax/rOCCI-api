module Occi
  module API
    # Contains various helper modules and classes shared with
    # the rest of the code. For details, see documentation
    # for the particular helper.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Helpers; end
  end
end

Dir[File.join(__dir__, 'helpers', '*.rb')].each { |file| require file.gsub('.rb', '') }
