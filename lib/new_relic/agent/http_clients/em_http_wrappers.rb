module NewRelic
  module Agent
    module HTTPClients

      class EmHttpRequest
        EM_HTTP = 'EM::HTTP'.freeze
        HOST = 'host'.freeze
        COLON = ':'.freeze

        def initialize(client, headers = nil)
          @client = client
          @headers = headers || @client.req.headers
        end

        def type
          EM_HTTP
        end

        def host_from_header
          if hostname = self[HOST]
            hostname.split(COLON).first
          end
        end

        def host
          @client.req.uri.host
        end

        def method
          @client.req.method
        end

        def [](key)
          @headers[key]
        end

        def []=(key, value)
          @headers[key] = value
        end

        def uri
          URI.parse @client.req.uri.to_s
        end
      end

      class EmHttpResponse
        def initialize(client)
          @client = client
        end

        def [](key)
          @client.response_header[key]
        end

        def to_hash
          @client.response_header.to_hash
        end
      end

    end
  end
end
