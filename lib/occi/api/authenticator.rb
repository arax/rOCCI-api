module Occi
  module API
    # @author Boris Parak <parak@cesnet.cz>
    class Authenticator
      include Yell::Loggable

      attr_accessor :type, :options

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
      # @return [String] token upon successfull authentication
      def token!
        auth_klass.new(options).authenticate!
      rescue KeyError => ex
        raise Occi::API::Errors::AuthenticationError, "#{self.class} requires additional options for #{type}: #{ex}"
      end

      # @see `token!`
      #
      # @return [String] token upon successfull authentication
      # @return [NilClass] upon authentication failure
      def token
        token!
      rescue Occi::API::Errors::AuthenticationError => ex
        logger.error "#{self.class} failed to obtain authentication token: #{ex}"
        nil
      end

      private

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
