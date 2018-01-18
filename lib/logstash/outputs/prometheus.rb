# encoding: utf-8
require "logstash/outputs/base"
require "logstash/namespace"
require 'json'
require_relative "alert_manager_client/client"

# An example output that does nothing.
class LogStash::Outputs::Prometheus < LogStash::Outputs::Base
  config_name "prometheus"
  @@alert_count = 0

  # url for alert manager connection
  config :url, :validate => :string, :required => true

  # path of the alert manager api
  config :path, :validate => :string, :default => '/api/v1/alerts'


  public
  def register

    begin 
  	  @am_client = AlertManagerClient::Client.new(url: @url, path: @path)
    rescue Errno::ECONNREFUSED => e
      @logger.warn("Connection refused to alert manager api.", :url => @url, :path => @path)
    end 

  end # def register

  public
  def receive(event)
    
    #@@alert_count += 1  
  	# @am.post '[{"labels":{"label1":"test"},"annotations":{"label2":"hello"},"startsAt":"2006-01-02T15:04:05.999999-07:00","endsAt":"2012-11-01T22:08:41+00:00","generatorURL":"fake_url"}]'
    #json_body = '[{"labels":{"label1":"test4_' + "#@@alert_count" + '"},' + '"annotations":{"label2":"hello"},"generatorURL":"fake_url"}]'
  	#@am.post json_body

    alert = Hash.new
    initialize_alert(alert)

    event.to_hash.each do |key, value|
      case key
      when 'title'
        alert['labels']['alertname'] = value
        alert['annotations']['summary'] = value
      when 'severity', 'project', 'component', 'item'
        alert['labels'][key] = value
      when 'description'
        alert['annotations']['description'] = value
      else
      end
    end

    alert_json = alert.to_json
    alert_json = '[' + alert_json + ']'
    # p alert_json # print out
    @am_client.post alert_json

  end # def event

  private
  def initialize_alert(alert)
    alert['annotations'] = Hash.new
    alert['labels'] = Hash.new
    alert['startsAt'] = Time.now.to_datetime.rfc3339
    #alert['endsAt'] = ''
    #alert['generatorURL'] = ''
    alert['labels']['instance'] = 'syslog'

    alert['labels']['alertname'] = 'Default Alert'
    alert['annotations']['summary'] = "Default Summary"
    alert['labels']['severity'] = '5'
    alert['labels']['project'] = 'NM'
    alert['labels']['component'] = 'Passive Monitoring'
  end
end # class LogStash::Outputs::Prometheus
