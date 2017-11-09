module Occi
  module API
    module Clients
      # @author Boris Parak <parak@cesnet.cz>
      class Model
        include Yell::Loggable
        include Helpers::Connector

        DELEGATED_METHODS = %i[
          kinds mixins actions categories
          find_related find_dependent find_by_identifier find_by_identifier!
          find_os_tpls find_resource_tpls find_availability_zones find_regions find_floatingippools
          instance_builder
        ].freeze
        delegate(*DELEGATED_METHODS, to: :model, prefix: false)

        attr_accessor :endpoint, :credentials, :options

        # @param args [Hash] client options
        def initialize(args = {})
          @endpoint = normalize_endpoint(args.fetch(:endpoint))
          @credentials = args.fetch(:credentials)
          @options = args.fetch(:options, {})

          flush!
        end

        # @return [Occi::InfrastructureExt::Model] server's model
        def model
          return @_model if @_model
          @_model = pull_model(endpoint).body
        end

        def flush!
          @_model = nil
        end
        alias reset! flush!
      end
    end
  end
end
