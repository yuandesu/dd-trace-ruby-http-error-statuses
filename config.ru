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

# When true, attach error.type / error.message / error.stack to 4xx spans
# so they are tracked as Issues in Error Tracking
ERROR_TRACKING_ENABLED = ENV.fetch('ERROR_TRACKING_ENABLED', 'false') == 'true'

def tag_error(span, type, message)
  err = StandardError.new(message)
  err.set_backtrace(caller)
  # Sets error.type, error.message, error.stack on the span
  span.set_error(err)
  # Override error.type with a descriptive name
  span.set_tag('error.type', type)
end

app = lambda do |env|
  req = Rack::Request.new(env)

  case req.path
  when '/ok'
    [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']]

  when '/forbidden'
    if ERROR_TRACKING_ENABLED
      span = Datadog::Tracing.active_span
      tag_error(span, 'ForbiddenError', 'Access forbidden') if span
    end
    [403, { 'Content-Type' => 'application/json' }, ['{"error":"Forbidden"}']]

  when '/unprocessable'
    if ERROR_TRACKING_ENABLED
      span = Datadog::Tracing.active_span
      tag_error(span, 'UnprocessableEntityError', 'Unprocessable entity') if span
    end
    [422, { 'Content-Type' => 'application/json' }, ['{"error":"Unprocessable Entity"}']]

  else
    [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not Found"}']]
  end
end

run app
