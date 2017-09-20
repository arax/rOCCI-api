module Occi
  module API
    module Auth
      # @author Boris Parak <parak@cesnet.cz>
      class Token
        include Yell::Loggable

        attr_accessor :credentials

        # @param args [Hash] hash with arguments
        # @option args [Hash] :credentials additional data for the selected authentication method
        def initialize(args = {})
          @credentials = args.fetch(:credentials)
        end

        # Performs external authentication and returns a token that can be
        # passed directly to `Occi::API::Client` instances for direct endpoint access.
        #
        # @param scope [String] authenticate within this scope (project, group, ...)
        # @param token [String] token for scoped authentication, if scope is given
        # @return [String] token upon successfull authentication
        def authenticate!(scope = nil, _token = nil)
          if credentials[:token].blank?
            raise Occi::API::Errors::AuthenticationError, 'Authentication token not provided'
          end
          logger.warn { "#{self.class} direct token authentication ignores dynamically provided scope" } if scope
          credentials[:token]
        end

        # Returns a list of available scopes which can be used later for scoped token retrieval.
        #
        # @example
        #    scopes "MY_TOKEN" # => [{ id: '1', name: 'project1' }, { id: '2', name: 'project2' }]
        #
        # @param token [String] unscoped token
        # @return [Array] list of available scopes
        def scopes(_token)
          [] # there are no scopes in direct token authentication
        end
      end
    end
  end
end
