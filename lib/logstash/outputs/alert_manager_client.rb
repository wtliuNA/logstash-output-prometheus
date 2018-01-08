# encoding: UTF-8

require 'uri'
require 'openssl'
require 'alert_manager_client/client'

# Alert Client is a ruby implementation for a Prometheus-alert-buffer client.
module AlertManagerClient
  def self.client(options = {})
    Client.new(options)
  end
end