# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require_relative "alert_manager_client/client"

# An example output that does nothing.
class LogStash::Outputs::Prometheus < LogStash::Outputs::Base
  config_name "prometheus"

  public
  def register

  	@am = AlertManagerClient::Client.new(url: 'http://localhost:9093', path: '/api/v1/alerts')

  end # def register

  public
  def receive(event)
  	@am.post '{"alertname": "test", "severity": "info"}'
    return "Event received"
  end # def event
end # class LogStash::Outputs::Prometheus
