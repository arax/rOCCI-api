module Occi
  module API
    module Clients
      # @author Boris Parak <parak@cesnet.cz>
      class Instances
        include Yell::Loggable
        include Helpers::Connector

        attr_accessor :endpoint, :credentials, :model, :options

        # @param args [Hash] client options
        def initialize(args = {})
          @endpoint = base_endpoint(args.fetch(:endpoint))
          @credentials = args.fetch(:credentials)
          @model = args.fetch(:model)
          @options = args.fetch(:options, {})
        end

        #
        #
        # @param kind [Occi::Core::Kind]
        # @return [Array]
        def list(kind)
          raise ArgumentError, '`kind` is a required argument' unless kind
          locations = pull_locations(kind.location).body
          locations.uris.to_a
        end

        #
        #
        # @param kind [Occi::Core::Kind]
        # @param filter [Hash]
        # @return [Occi::Core::Collection]
        def describe(kind, filter = {})
          filtered_collection(kind, filter)
        end

        #
        #
        # @param instance [Occi::Core::Entity]
        # @return [URI]
        def create(instance); end

        #
        #
        # @param instance [Occi::Core::Entity]
        # @return [URI]
        def update(instance); end

        #
        #
        # @param instance [Occi::Core::Entity]
        # @return [URI]
        def partial_update(instance); end

        #
        #
        # @param kind [Occi::Core::Kind]
        # @param filter [Hash]
        # @return [Array]
        def delete(kind, filter = {})
          locations = Occi::Core::Locations.new

          entities = filtered_collection(kind, filter).entities
          entities.each do |entity|
            make(:delete, entity.location)
            locations << entity.location
          end
          locations.valid!

          locations
        end

        #
        #
        # @param instance [Occi::Core::Entity]
        # @param action_instance [Occi::Core::ActionInstance]
        # @return [URI]
        def action(instance, action_instance); end

        private

        # :nodoc:
        def filtered_collection(kind, filter)
          raise ArgumentError, '`kind` is a required argument' unless kind
          filter ||= {}

          instances = pull_instances(kind.location).body
          instances.entities.keep_if { |e| filter.reduce(true) { |memo, (k, v)| memo && e[k.to_s] == v } }

          instances
        end
      end
    end
  end
end
