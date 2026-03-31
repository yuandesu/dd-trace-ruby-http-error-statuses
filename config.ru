# frozen_string_literal: true

require 'datadog'
require 'rack'
require 'json'

Datadog.configure do |c|
  c.service = ENV.fetch('DD_SERVICE', 'demo-app')
  c.env     = ENV.fetch('DD_ENV', 'local')
  c.tracing.instrument :rack
end

use Datadog::Tracing::Contrib::Rack::TraceMiddleware

# True only for the service that demonstrates Error Tracking integration.
# Other services return 4xx without setting error tags to show the difference.
ERROR_TRACKING_SERVICE = ENV.fetch('DD_SERVICE', '') == 'http-status-for-error-tracking'

app = lambda do |env|
  req = Rack::Request.new(env)

  case req.path
  when '/ok'
    [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']]

  when '/forbidden'
    if ERROR_TRACKING_SERVICE
      span = Datadog::Tracing.active_span
      if span
        err = StandardError.new('Access forbidden')
        err.set_backtrace(caller)
        # span.set_error sets span.status=1 AND error.type / error.message / error.stack
        # Required for Error Tracking to create Issues
        span.set_error(err)
      end
    end
    [403, { 'Content-Type' => 'application/json' }, ['{"error":"Forbidden"}']]

  when '/unprocessable'
    if ERROR_TRACKING_SERVICE
      span = Datadog::Tracing.active_span
      if span
        err = StandardError.new('Unprocessable entity')
        err.set_backtrace(caller)
        # span.set_error sets span.status=1 AND error.type / error.message / error.stack
        # Required for Error Tracking to create Issues
        span.set_error(err)
      end
    end
    [422, { 'Content-Type' => 'application/json' }, ['{"error":"Unprocessable Entity"}']]

  else
    [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not Found"}']]
  end
end

run app
