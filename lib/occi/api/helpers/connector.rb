module Occi
  module API
    module Helpers
      # @author Boris Parak <parak@cesnet.cz>
      module Connector
        MODEL_LOCATION = '/-/'.freeze

        # @param url [String] address to contact
        def pull_model(url)
          request = { type: :model }
          make(:get, MODEL_LOCATION, request)
        end

        # @param url [String] address to contact
        def pull_instances(url)
          request = { type: :instances, model: model }
          make(:get, url, request)
        end

        # @param url [String] address to contact
        def pull_locations(url)
          request = { type: :locations, model: model }
          make(:get, url, request)
        end

        # @param url [String] address to contact
        # @param collection [Occi::Core::Collection] collection of instances to send
        def push_instances(url, collection)
          request = { type: :instances, body: collection, model: model }
          make(:post, url, request)
        end

        # @param verb [Symbol] HTTP method to use
        # @param url [String] address to contact
        # @param request [Hash] request options
        def make(verb, url, request)
          raise ArgumentError, "`verb` is a required argument" if verb.blank?
          raise ArgumentError, "`url` is a required argument" if url.blank?
          raise ArgumentError, "`request` is a required argument" if request.blank?

          ff = Utils::FaradayFactory.new(credentials: credentials, options: options)
          ff.connection(request).send(verb) do |req|
            req.url "#{endpoint}#{url}"
            req.headers.merge! request.fetch(:headers, {})
            req.body = request[:body] if request[:body]
          end
        end

        # @param endpoint [String] endpoint to extract base from
        def base_endpoint(endpoint)
          endpoint = URI.parse(endpoint)

          endpoint.path = ''
          endpoint.fragment = nil
          endpoint.query = nil

          normalize_endpoint(endpoint.to_s)
        end

        # @param endpoint [String] endpoint to normalize
        def normalize_endpoint(endpoint)
          endpoint.chomp('/')
        end
      end
    end
  end
end
