module Occi
  module API
    module Utils
      # Reads certificates and keys from a file and converts them into OpenSSL::*
      # instances.
      #
      # @attr file [String] raw content of the file
      #
      # @author Boris Parak <parak@cesnet.cz>
      class X509Reader
        # Regexp for scanning proxy files
        CERT_REGEXP = /\n?(-----BEGIN CERTIFICATE-----\n.+?\n-----END CERTIFICATE-----)\n/m

        attr_reader :file

        # Creates an instance of the X.509 reader.
        #
        # @param args [Hash] arguments
        # @option args [String] :file path to a file
        def initialize(args = {})
          self.file = args.fetch(:file)
        end

        # Reads content of a file in `path` and assigns it.
        #
        # @example
        #    x.file = '/tmp/x509up_u1000'
        #
        # @param path [String] path to a file
        # @return [String] content of the file
        def file=(path)
          raise ArgumentError, "PKCS12 file #{path.inspect} is not supported" if path.end_with?('.p12')
          @file = File.read path
        end

        # Reads X.509 certificates into an array.
        #
        # @example
        #    x = X509Reader.new file: '/tmp/x509up_u1000'
        #    x.certificates # => [#<OpenSSL::X509::Certificate>, #<OpenSSL::X509::Certificate>, ...]
        #
        # @return [Array<OpenSSL::X509::Certificate>] An array of read certificates
        def certificates
          certs_ary = []
          file.scan(CERT_REGEXP) { |match| certs_ary << OpenSSL::X509::Certificate.new(match.first) }
          certs_ary
        end

        # Reads X.509 certificate.
        #
        # @example
        #    x = X509Reader.new file: '/tmp/x509up_u1000'
        #    x.certificate # => #<OpenSSL::X509::Certificate>
        #
        # @return [OpenSSL::X509::Certificate] Read certificate
        def certificate
          OpenSSL::X509::Certificate.new file
        end

        # Reads X.509 certificate key.
        #
        # @example
        #    x = X509Reader.new file: '/tmp/x509up_u1000'
        #    x.key # => #<OpenSSL::PKey::RSA>
        #
        # @return [OpenSSL::PKey::RSA] Read certificate key
        def key
          OpenSSL::PKey::RSA.new file
        end
      end
    end
  end
end
