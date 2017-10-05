module Occi::Api::Client
  module Http
    module AuthnPlugins
      class Keystone < Base
        KEYSTONE_URI_REGEXP = /^(Keystone|snf-auth) uri=("|')(.+)("|')$/
        KEYSTONE_VERSION_REGEXP = /^v([0-9]).*$/

        def setup(options = {})
          # get Keystone URL if possible
          set_keystone_base_url

          # discover Keystone API version
          @env_ref.class.headers.delete 'X-Auth-Token'

          keystone_version = '3' if @options[:type] == 'oauth2'
          set_auth_token ENV['ROCCI_CLIENT_KEYSTONE_TENANT'], keystone_version

          if @env_ref.class.headers['X-Auth-Token'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError, "Unable to get a tenant from Keystone, fallback failed!"
          end
        end

        def authenticate(options = {})
          # OCCI-OS doesn't support HEAD method!
          response = @env_ref.class.get "#{@env_ref.endpoint}/-/"
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Authentication failed with code #{response.code}!" unless response.success?
        end

        private

        def set_keystone_base_url
          response = @env_ref.class.get "#{@env_ref.endpoint}/-/"
          Occi::Api::Log.debug response.inspect

          return if response.success?
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Keystone AuthN failed with #{response.code}!" unless response.unauthorized?

          process_headers response
        end

        def process_headers(response)
          authN_header = response.headers['www-authenticate']

          if authN_header.blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Response does not contain the www-authenticate header, fallback failed!"
          end

          match = KEYSTONE_URI_REGEXP.match(authN_header)
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Unable to get Keystone's URL from the response, fallback failed!" unless match && match[3]

          @keystone_url = match[3]
        end

        def set_auth_token(tenant = nil, keystone_version = nil)
          response = @env_ref.class.get(@keystone_url, :headers => get_req_headers)
          Occi::Api::Log.debug response.inspect

          unless response.success? || response.multiple_choices?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  'Unable to get Keystone API version from the response, fallback failed!'
          end

          versions = if response.multiple_choices?
                       response['versions']['values'].sort_by { |v| v['id'] } # multiple versions, sort by version id
                     else
                       [response['version']] # assume a single version
                     end

          versions.each do |v|
            match = KEYSTONE_VERSION_REGEXP.match(v['id'])
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get Keystone API version from the response, fallback failed!" unless match && match[1]
            next if keystone_version && keystone_version != match[1]

            handler_class = match[1] == '3' ? KeystoneV3 : KeystoneV2
            v['links'].each do |link|
              begin
                next unless link['rel'] == 'self'

                keystone_url = link['href'].chomp('/')
                keystone_handler = handler_class.new(keystone_url, @env_ref, @options)
                keystone_handler.set_auth_token tenant

                return # found a working keystone, stop looking
              rescue ::Occi::Api::Client::Errors::AuthnError
                # ignore and try with next link
              end
            end
          end
        end

        def get_req_headers
          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = "application/json"
          headers['Accept'] = headers['Content-Type']

          headers
        end
      end

      class KeystoneV2
        def initialize(base_url, env_ref, options = {})
          @base_url = base_url
          @env_ref = env_ref
          @options = options
        end

        def set_auth_token(tenant = nil)
          if tenant.blank?
            # get an unscoped token, use the unscoped token
            # for tenant discovery and get a scoped token
            authenticate
            get_first_working_tenant
          else
            authenticate tenant
          end
        end

        def authenticate(tenant = nil)
          response = @env_ref.class.post(
            "#{@base_url}/tokens",
            :body => get_keystone_req(tenant),
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          if !response.success? || response['access'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
          end

          @env_ref.class.headers['X-Auth-Token'] = response['access']['token']['id']
        end

        def get_keystone_req(tenant = nil)
          if @options[:original_type] == "x509"
            body = { "auth" => { "voms" => true } }
          elsif @options[:username] && @options[:password]
            body = {
              "auth" => {
                "passwordCredentials" => {
                  "username" => @options[:username],
                  "password" => @options[:password]
                }
              }
            }
          else
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to request a token from Keystone! Chosen " \
                  "AuthN is not supported, fallback failed!"
          end

          body['auth']['tenantName'] = tenant unless tenant.blank?
          body.to_json
        end

        def get_first_working_tenant
          response = @env_ref.class.get(
            "#{@base_url}/tenants",
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          if !response.success? || response['tenants'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Keystone didn't return any tenants, fallback failed!"
          end

          response['tenants'].each do |tenant|
            begin
              Occi::Api::Log.debug "Authenticating for tenant #{tenant['name'].inspect}"
              authenticate tenant['name']
              break # found a working tenant, stop looking
            rescue ::Occi::Api::Client::Errors::AuthnError
              # ignoring and trying the next tenant
            end
          end
        end

        def get_req_headers
          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = "application/json"
          headers['Accept'] = headers['Content-Type']

          headers
        end
      end

      class KeystoneV3
        def initialize(base_url, env_ref, options = {})
          @base_url = base_url
          @env_ref = env_ref
          @options = options
        end

        def set_auth_token(tenant = nil)
          if @options[:original_type] == "x509"
            set_voms_unscoped_token
          elsif @options[:type] == "oauth2"
            set_oauth2_unscoped_token
          elsif @options[:username] && @options[:password]
            passwd_authenticate
          else
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to request a token from Keystone! Chosen AuthN is not supported, fallback failed!"
          end

          tenant.blank? ? get_first_working_project : set_scoped_token(tenant)
        end

        def passwd_authenticate
          raise ::Occi::Api::Client::Errors::AuthnError,
                "Needs to be implemented, check http://developer.openstack.org/api-ref-identity-v3.html#authenticatePasswordUnscoped"
        end

        def set_voms_unscoped_token
          response = @env_ref.class.get(
            # FIXME(enolfc) egi.eu and mapped below should be configurable
            "#{@base_url}/OS-FEDERATION/identity_providers/egi.eu/protocols/mapped/auth",
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          if !response.success? || response.headers['x-subject-token'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
          end

          @env_ref.class.headers['X-Auth-Token'] = response.headers['x-subject-token']
        end

        def set_oauth2_unscoped_token
          headers = get_req_headers
          headers['Authorization'] = "Bearer #{@options[:token]}"
          response = @env_ref.class.get(
            # FIXME(enolfc) egi.eu and oidc below should be configurable
            "#{@base_url}/OS-FEDERATION/identity_providers/egi.eu/protocols/oidc/auth",
            :headers => headers
          )
          Occi::Api::Log.debug response.inspect

          if !response.success? || response.headers['x-subject-token'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
          end

          @env_ref.class.headers['X-Auth-Token'] = response.headers['x-subject-token']
        end

        def get_first_working_project
          response = @env_ref.class.get(
            "#{@base_url}/auth/projects",
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          if !response.success? || response['projects'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Keystone didn't return any projects, fallback failed!"
          end

          response['projects'].each do |project|
            begin
              Occi::Api::Log.debug "Authenticating for project #{project['name'].inspect}"
              set_scoped_token project['id']
              break # found a working project, stop looking
            rescue ::Occi::Api::Client::Errors::AuthnError
              # ignoring and trying the next tenant
            end
          end
        end

        def set_scoped_token(project)
          body = {
            "auth" => {
              "identity" => {
                "methods" => ["token"],
                "token" => { "id" => @env_ref.class.headers['X-Auth-Token'] }
              },
              "scope" => {
                "project" => { "id" => project }
              }
            }
          }

          response = @env_ref.class.post(
            "#{@base_url}/auth/tokens",
            :body => body.to_json,
            :headers => get_req_headers
          )
          Occi::Api::Log.debug response.inspect

          if !response.success? || response.headers['x-subject-token'].blank?
            raise ::Occi::Api::Client::Errors::AuthnError,
                  "Unable to get a token from Keystone, fallback failed!"
          end

          @env_ref.class.headers['X-Auth-Token'] = response.headers['x-subject-token']
        end

        def get_req_headers
          headers = @env_ref.class.headers.clone
          headers['Content-Type'] = 'application/json'
          headers['Accept'] = headers['Content-Type']

          headers
        end
      end
    end
  end
end
