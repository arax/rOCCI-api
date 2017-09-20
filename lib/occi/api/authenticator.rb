module Occi
  module API
    # @author Boris Parak <parak@cesnet.cz>
    class Authenticator
      include Yell::Loggable

      attr_accessor :type, :options

      delegate :scopes, to: :auth_instance

      # @param args [Hash] hash with arguments
      # @option args [Symbol] :type authentication type
      # @option args [Hash] :options options for authentication
      def initialize(args = {}, &block)
        @type = args.fetch(:type)
        @options = args.fetch(:options, proptions(block))
      end

      # Performs external authentication and returns a token that can be
      # passed directly to `Occi::API::Client` instances for direct endpoint access.
      #
      # @param scope [String] token for this scope (project, group, ...)
      # @param token [String] token for scoped authentication, if scope is given
      # @return [String] token upon successfull authentication
      def token!(scope = nil, token = nil)
        auth_instance.authenticate! scope, token
      rescue KeyError => ex
        raise Occi::API::Errors::AuthenticationError, "#{self.class} requires additional options for #{type}: #{ex}"
      end

      # @see `token!`
      #
      # @param scope [String] token for this scope (project, group, ...)
      # @param token [String] token for scoped authentication, if scope is given
      # @return [String] token upon successfull authentication
      # @return [NilClass] upon authentication failure
      def token(scope = nil, token = nil)
        token! scope, token
      rescue Occi::API::Errors::AuthenticationError => ex
        logger.error { "#{self.class} failed to obtain authentication token: #{ex}" }
        nil
      end

      # Resets internal structures and reloads options. This should be triggered when changing `options`
      # or `type` in runtime via attribute accessors.
      def flush!
        @_auth = nil
      end
      alias reset! flush!

      private

      # :nodoc:
      def auth_instance
        @_auth ||= auth_klass.new(options)
      end

      # :nodoc:
      def proptions(block)
        opts = {}
        block.call(opts) if block
        opts
      end

      # :nodoc:
      def auth_klass
        Auth.const_get type.to_s.classify
      rescue NameError
        raise Occi::API::Errors::AuthenticationError, "#{self.class} does not support type #{type.to_s.inspect}"
      end
    end
  end
end
