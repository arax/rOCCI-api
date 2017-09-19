module Occi
  module API
    module Auth
      # @author Boris Parak <parak@cesnet.cz>
      module KeystoneVersions; end

      # @author Boris Parak <parak@cesnet.cz>
      class Keystone
        include Yell::Loggable

        attr_reader :version
        attr_accessor :type, :endpoint, :credentials

        # @param args [Hash] hash with arguments
        # @option args [String] :version Keystone API version
        # @option args [Symbol] :type authentication type
        # @option args [String] :endpoint authentication endpoint
        # @option args [Hash] :credentials additional data for the selected authentication type
        def initialize(args = {})
          @version = args.fetch(:version, 'v3')
          @type = args.fetch(:type)
          @endpoint = args.fetch(:endpoint)
          @credentials = args.fetch(:credentials)

          insert_api!
        end

        # Performs external authentication and returns a token that can be
        # passed directly to `Occi::API::Client` instances for direct endpoint access.
        #
        # @return [String] token upon successfull authentication
        def authenticate!
          type_method = "authenticate_#{type}!"
          unless respond_to?(type_method)
            raise Occi::API::Errors::AuthenticationError, "#{self.class} does not support type #{type.to_s.inspect}"
          end

          send type_method
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
