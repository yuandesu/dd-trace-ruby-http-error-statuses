# frozen_string_literal: true

require 'datadog'
require 'rack'
require 'json'

# SCENARIO controls app behavior:
#   before - default: DD_TRACE_HTTP_SERVER_ERROR_STATUSES not set (only 500-599 are errors)
#   after  - DD_TRACE_HTTP_SERVER_ERROR_STATUSES=403,422,500-599 (403/422 → span.status=1)
SCENARIO = ENV.fetch('SCENARIO', 'before')

Datadog.configure do |c|
  c.service = ENV.fetch('DD_SERVICE', 'demo-app')
  c.env     = ENV.fetch('DD_ENV', 'local')
  c.tracing.instrument :rack
end

use Datadog::Tracing::Contrib::Rack::TraceMiddleware

app = lambda do |env|
  req = Rack::Request.new(env)

  case req.path
  when '/ok'
    [200, { 'Content-Type' => 'application/json' },
     [{ status: 'ok', scenario: SCENARIO }.to_json]]

  when '/forbidden'
    [403, { 'Content-Type' => 'application/json' },
     [{ error: 'Forbidden', scenario: SCENARIO }.to_json]]

  when '/unprocessable'
    [422, { 'Content-Type' => 'application/json' },
     [{ error: 'Unprocessable Entity', scenario: SCENARIO }.to_json]]

  else
    [404, { 'Content-Type' => 'application/json' },
     [{ error: 'Not Found' }.to_json]]
  end
end

run app
