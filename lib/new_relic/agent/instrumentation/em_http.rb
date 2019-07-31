DependencyDetection.defer do

  named :em_http

  depends_on do
    defined?(EM::HTTPMethods)
  end

  executes do
    ::NewRelic::Agent.logger.info 'Installing EM::HTTP instrumentation'
    require 'new_relic/agent/cross_app_tracing'
    require 'new_relic/agent/http_clients/em_http_wrappers'
  end

  executes do
    class EventMachine::HttpClient
      def initialize_with_newrelic(conn, options)
        initialize_without_newrelic(conn, options)

        wrapped_request = ::NewRelic::Agent::HTTPClients::EmHttpRequest.new(self)
        @newrelic_segment = ::NewRelic::Agent::Tracer.start_external_request_segment(
          library: wrapped_request.type,
          uri: wrapped_request.uri,
          procedure: wrapped_request.method
        )
      end

      alias_method :initialize_without_newrelic, :initialize
      alias_method :initialize, :initialize_with_newrelic

      def send_request_with_newrelic(head, body)
        wrapped_request = ::NewRelic::Agent::HTTPClients::EmHttpRequest.new(self, head)
        @newrelic_segment.add_request_headers wrapped_request

        send_request_without_newrelic(head, body)
      end

      alias_method :send_request_without_newrelic, :send_request
      alias_method :send_request, :send_request_with_newrelic

      def succeed_with_newrelic(client)
        wrapped_response = ::NewRelic::Agent::HTTPClients::EmHttpResponse.new(self)
        @newrelic_segment.read_response_headers wrapped_response
        @newrelic_segment.finish

        succeed_without_newrelic(client)
      end

      alias_method :succeed_without_newrelic, :succeed
      alias_method :succeed, :succeed_with_newrelic
    end
  end
end
