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
    class EventMachine::HttpConnection
      def activate_connection_with_newrelic(client)
        wrapped_request = ::NewRelic::Agent::HTTPClients::EmHttpRequest.new(client)

        client.newrelic_segment = ::NewRelic::Agent::Transaction.start_external_request_segment(
          wrapped_request.type, wrapped_request.uri, wrapped_request.method
        )

        client.callback do
          wrapped_response = ::NewRelic::Agent::HTTPClients::EmHttpResponse.new(client)
          client.newrelic_segment.read_response_headers wrapped_response
          client.newrelic_segment.finish
        end

        activate_connection_without_newrelic(client)
      end

      alias_method :activate_connection_without_newrelic, :activate_connection
      alias_method :activate_connection, :activate_connection_with_newrelic
    end
  end

  executes do
    class EventMachine::HttpClient
      attr_accessor :newrelic_segment

      def send_request_with_newrelic(head, body)
        wrapped_request = ::NewRelic::Agent::HTTPClients::EmHttpRequest.new(self, head)
        newrelic_segment.add_request_headers wrapped_request
        send_request_without_newrelic(head, body)
      end

      alias_method :send_request_without_newrelic, :send_request
      alias_method :send_request, :send_request_with_newrelic
    end
  end

end
