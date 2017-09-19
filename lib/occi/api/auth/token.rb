module Occi
  module API
    module Auth
      # @author Boris Parak <parak@cesnet.cz>
      class Token
        include Yell::Loggable

        # @param args [Hash] hash with arguments
        # @option args [Hash] :credentials additional data for the selected authentication method
        def initialize(args = {})
          @credentials = args.fetch(:credentials)
        end

        # Performs external authentication and returns a token that can be
        # passed directly to `Occi::API::Client` instances for direct endpoint access.
        #
        # @return [String] token upon successfull authentication
        def authenticate!
          if credentials[:token].blank?
            raise Occi::API::Errors::AuthenticationError, 'Authentication token not provided'
          end
          credentials[:token]
        end
      end
    end
  end
end
