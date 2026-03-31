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

app = lambda do |env|
  req = Rack::Request.new(env)

  case req.path
  when '/ok'
    [200, { 'Content-Type' => 'application/json' }, ['{"status":"ok"}']]

  when '/forbidden'
    [403, { 'Content-Type' => 'application/json' }, ['{"error":"Forbidden"}']]

  when '/unprocessable'
    [422, { 'Content-Type' => 'application/json' }, ['{"error":"Unprocessable Entity"}']]

  else
    [404, { 'Content-Type' => 'application/json' }, ['{"error":"Not Found"}']]
  end
end

run app
