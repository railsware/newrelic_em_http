require 'newrelic_rpm'

NewRelic::Control.instance.add_instrumentation File.expand_path(
  File.join(__dir__, 'new_relic', 'agent','instrumentation', 'em_http.rb')
)
