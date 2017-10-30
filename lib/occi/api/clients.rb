module Occi
  module API
    # Contains various client modules and classes exposing
    # end-user functionality. For details, see documentation
    # for the particular client.
    #
    # @author Boris Parak <parak@cesnet.cz>
    module Clients; end
  end
end

Dir[File.join(__dir__, 'clients', '*.rb')].each { |file| require file.gsub('.rb', '') }
