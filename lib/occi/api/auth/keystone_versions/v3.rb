module Occi
  module API
    module Auth
      module KeystoneVersions
        # @author Boris Parak <parak@cesnet.cz>
        module V3
          # @return [String] token upon successfull authentication
          def authenticate_voms!; end

          # @return [String] token upon successfull authentication
          def authenticate_oidc!; end
        end
      end
    end
  end
end
