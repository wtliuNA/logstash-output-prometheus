# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'json'
require_relative "alert_manager_client/client"

# An example output that does nothing.
class LogStash::Outputs::Prometheus < LogStash::Outputs::Base
  config_name "prometheus"
  @@alert_count = 0

  public
  def register

  	@am = AlertManagerClient::Client.new(url: 'http://localhost:9093', path: '/api/v1/alerts')
  end # def register

  public
  def receive(event)
        #time_start = Time.now.to_datetime.rfc3339
        #sleep(1)
        @@alert_count += 1  
  	# @am.post '[{"labels":{"label1":"test"},"annotations":{"label2":"hello"},"startsAt":"2006-01-02T15:04:05.999999-07:00","endsAt":"2012-11-01T22:08:41+00:00","generatorURL":"fake_url"}]'
  	json_body = '[{"labels":{"label1":"test4_' + "#@@alert_count" + '"},' + '"annotations":{"label2":"hello"},"generatorURL":"fake_url"}]'
  	@am.post json_body
  end # def event
end # class LogStash::Outputs::Prometheus
