module Occi
  module API
    module Auth
      # @author Boris Parak <parak@cesnet.cz>
      module KeystoneVersions; end

      # @author Boris Parak <parak@cesnet.cz>
      class Keystone
        include Yell::Loggable

        DEFAULT_VERSION = 'v3'.freeze
        DEFAULT_CONTENT_TYPE = 'application/json'.freeze

        attr_reader :version
        attr_accessor :type, :endpoint, :credentials

        # @param args [Hash] hash with arguments
        # @option args [String] :version Keystone API version
        # @option args [Symbol] :type authentication type
        # @option args [String] :endpoint authentication endpoint
        # @option args [Hash] :credentials additional data for the selected authentication type
        def initialize(args = {})
          @version = args.fetch(:version, DEFAULT_VERSION)
          @type = args.fetch(:type)
          @endpoint = args.fetch(:endpoint).chomp('/')
          @credentials = args.fetch(:credentials)

          insert_api!
        end

        # Performs external authentication and returns a token that can be
        # passed directly to `Occi::API::Client` instances for direct endpoint access.
        #
        # @param scope [String] authenticate within this scope (project, group, ...)
        # @param token [String] token for scoped authentication, if scope is given
        # @return [String] token upon successfull authentication
        def authenticate(scope, token)
          typed! :authenticate, scope, token
        end
        alias authenticate! authenticate

        # Returns a list of available scopes which can be used later for scoped token retrieval.
        #
        # @example
        #    scopes "MY_TOKEN" # => [{ id: '1', name: 'project1' }, { id: '2', name: 'project2' }]
        #
        # @param token [String] unscoped token
        # @return [Array] list of available scopes
        def scopes(token)
          typed! :scopes, token
        end
        alias scopes! scopes

        private

        # :nodoc:
        def typed!(prefix, *args)
          type_method = "#{prefix}_#{type}!"
          unless respond_to?(type_method)
            raise Occi::API::Errors::AuthenticationError,
                  "#{self.class} does not support type #{type.to_s.inspect} in version #{version.inspect}"
          end

          send type_method, *args
        end

        # :nodoc:
        def insert_api!
          instance_eval { extend(version_klass) }
        end

        # :nodoc:
        def version_klass
          KeystoneVersions.const_get version.classify
        rescue NameError
          raise Occi::API::Errors::AuthenticationError, "#{self.class} in version #{version.inspect} is not supported"
        end

        # :nodoc:
        def make(verb, relative_url, request = {})
          connection_factory(request).send(verb) do |req|
            req.url "#{endpoint}#{relative_url}"
            req.headers['Accept'] = DEFAULT_CONTENT_TYPE
            req.headers['Content-Type'] = DEFAULT_CONTENT_TYPE
            req.headers.merge! request[:headers] if request[:headers]
            req.body = request[:body] if request[:body]
          end
        rescue Faraday::Error::ClientError => ex
          raise Occi::API::Errors::AuthenticationError, ex.message
        end

        # :nodoc:
        def connection_factory(opts)
          Faraday.new do |faraday|
            connection_middleware faraday, opts
            faraday.ssl.merge! opts[:ssl] if opts[:ssl]
            faraday.adapter :net_http
          end
        end

        # :nodoc:
        def connection_middleware(faraday, opts)
          # Request
          faraday.request :token, opts[:token] if opts[:token]
          faraday.request :oauth2, opts[:oauth2], token_type: 'bearer' if opts[:oauth2]
          faraday.request :json
          # Response
          faraday.response :json
          faraday.response :raise_error
          faraday.response :logger, logger
        end
      end
    end
  end
end

Dir[File.join(__dir__, 'keystone_versions', '*.rb')].each { |file| require file.gsub('.rb', '') }
