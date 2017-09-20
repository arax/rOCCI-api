module Occi
  module API
    module Auth
      module KeystoneVersions
        # @author Boris Parak <parak@cesnet.cz>
        module V3
          GLOBAL_PREFIX = '/v3'.freeze
          PROJECT_URL = "#{GLOBAL_PREFIX}/auth/projects".freeze
          TOKEN_URL = "#{GLOBAL_PREFIX}/auth/tokens".freeze
          FED_URL = "#{GLOBAL_PREFIX}/OS-FEDERATION/identity_providers/%PROVIDER%/protocols/%TYPE%/auth".freeze
          SUBJECT_TOKEN_HEADER = 'X-Subject-Token'.freeze

          # @param scope [String] authenticate within this scope (project, group, ...)
          # @param token [String] token for scoped authentication, if scope is given
          # @return [String] token upon successfull authentication
          def authenticate_voms!(scope, token)
            return authenticate_scoped!(scope, token) if scope

            # unscoped
            url = federated_url.gsub('%TYPE%', 'mapped')
            response = make(:post, url, ssl: ssl_opts)
            response.headers[SUBJECT_TOKEN_HEADER]
          end

          # @param scope [String] authenticate within this scope (project, group, ...)
          # @param token [String] token for scoped authentication, if scope is given
          # @return [String] token upon successfull authentication
          def authenticate_oidc!(scope, token)
            return authenticate_scoped!(scope, token) if scope

            # unscoped
            url = federated_url.gsub('%TYPE%', 'oidc')
            response = make(:post, url, ssl: ssl_opts, oauth2: credentials[:token])
            response.headers[SUBJECT_TOKEN_HEADER]
          end

          # @param scope [String] authenticate within this scope (project, group, ...)
          # @param token [String] token for scoped authentication, if scope is given
          # @return [String] token upon successfull authentication
          def authenticate_scoped!(scope, token)
            if scope.blank? || token.blank?
              raise Occi::API::Errors::AuthenticationError, '`scope` and `token` are mandatory arguments'
            end

            body = {
              auth: {
                identity: { methods: ['token'], token: { id: token } },
                scope: { project: { id: scope } }
              }
            }
            response = make(:post, TOKEN_URL, ssl: ssl_opts, body: body)
            response.headers[SUBJECT_TOKEN_HEADER]
          end

          # Returns a list of available scopes which can be used later for scoped token retrieval.
          #
          # @example
          #    scopes "MY_TOKEN" # => [{ id: '1', name: 'project1' }, { id: '2', name: 'project2' }]
          #
          # @param token [String] unscoped token
          # @return [Array] list of available scopes
          def scopes_all!(token)
            if token.blank?
              raise Occi::API::Errors::AuthenticationError, "#{self.class} requires token for scope retrieval"
            end

            response = make(:get, PROJECT_URL, ssl: ssl_opts, token: token)
            response.body['projects'].map { |p| { id: p['id'], name: p['name'] } }
          end
          alias scopes_voms! scopes_all!
          alias scopes_oidc! scopes_all!

          # :nodoc:
          def federated_url
            FED_URL.gsub('%PROVIDER%', credentials[:identity_provider])
          end

          # :nodoc:
          def ssl_opts
            default_ssl.merge credentials.fetch(:ssl, {})
          end

          # :nodoc:
          def default_ssl
            { verify: true }
          end
        end
      end
    end
  end
end
