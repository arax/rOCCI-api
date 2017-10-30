module Occi
  module API
    module Clients
      # @author Boris Parak <parak@cesnet.cz>
      class Instances
        include Yell::Loggable
        include Helpers::Faraday

        attr_accessor :endpoint, :credentials, :model, :options

        # @param args [Hash] client options
        def initialize(args = {})
          @endpoint = args.fetch(:endpoint)
          @credentials = args.fetch(:credentials)
          @model = args.fetch(:model)
          @options = args.fetch(:options, {})
        end

        #
        def list(kind); end

        #
        def describe(kind, id = nil); end

        #
        def create(instance); end

        #
        def update(instance); end

        #
        def partial_update(instance); end

        #
        def delete(kind, id = nil); end

        #
        def action(instance, action_instance); end
      end
    end
  end
end
