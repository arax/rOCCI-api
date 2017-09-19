module Occi
  module API
    module Auth
      # @author Boris Parak <parak@cesnet.cz>
      module KeystoneVersions; end

      # @author Boris Parak <parak@cesnet.cz>
      class Keystone
        include Yell::Loggable

        attr_reader :version
        attr_writer :method, :endpoint, :credentials

        # @param args [Hash] hash with arguments
        # @option args [String] :version Keystone API version
        # @option args [Symbol] :method authentication method
        # @option args [String] :endpoint authentication endpoint
        # @option args [Hash] :credentials additional data for the selected authentication method
        def initialize(args = {})
          @version = args.fetch(:version, 'v3')
          @method = args.fetch(:method)
          @endpoint = args.fetch(:endpoint)
          @credentials = args.fetch(:credentials)

          insert_api!
        end

        # Performs external authentication and returns a token that can be
        # passed directly to `Occi::API::Client` instances for direct endpoint access.
        #
        # @return [String] token upon successfull authentication
        def authenticate!
          m_name = "authenticate_#{method}!"
          unless respond_to?(m_name)
            raise Occi::API::Errors::AuthenticationError, "#{self.class} does not support method #{method.to_s.inspect}"
          end

          send m_name
        end

        private

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
      end
    end
  end
end

Dir[File.join(__dir__, 'keystone_versions', '*.rb')].each { |file| require file.gsub('.rb', '') }
