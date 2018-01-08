# encoding: UTF-8

require 'json'
require 'faraday'
require 'faraday_middleware'


module AlertManagerClient
  # Client contains the implementation for an alert_manager_client.
  class Client
    class RequestError < StandardError; end

    # Default parameters for creating default client
    DEFAULT_ARGS = {
      path: '/api/v1/alerts',
      credentials: {},
      options: {
        open_timeout: 2,
        timeout: 5,
      },
    }.freeze

    # Create a Prometheus Alert client:
    #
    # @param [Hash] options
    # @option options [String] :url server base URL.
    # @option options [Hash] :credentials Authentication credentials.
    # @option options [Hash] :options Options used to define connection.
    # @option options [Hash] :params URI query unencoded key/value pairs.
    # @option options [Hash] :headers Unencoded HTTP header key/value pairs.
    # @option options [Hash] :request Request options.
    # @option options [Hash] :ssl SSL options.
    # @option options [Hash] :proxy Proxy options.
    #
    # A default client is created if options is omitted.
    def initialize(options = {})
      options = DEFAULT_ARGS.merge(options)

      @client = Faraday.new(
        faraday_options(options),
      ) do |conn|
        conn.response(:json)
        conn.adapter(Faraday.default_adapter)
      end
    end

    # Get alerts:
    #
    # @param [Hash] options
    # @option options [String] :generation_id Database generation Id.
    # @option options [Integer] :from_index Minimal index of alerts to fetch.
    #
    # @return [Hash] response with keys: generationID, messages
    # All alerts will be fetched if options are omitted.
    def get(options = {})
      response = @client.get do |req|
        req.params['generationID'] = options[:generation_id]
        req.params['fromIndex'] = options[:from_index]
      end

      response.body
    end

    # post alert:
    # @param [String] alert Alert to post
    def post(alert)
      @client.post do |req|
        req.body = alert
      end
    end

    # Helper function to evalueate the low level proxy option
    def faraday_proxy(options)
      return options[:proxy] if options[:proxy]

      proxy = options[:options]
      proxy[:http_proxy_uri] if proxy[:http_proxy_uri]
    end

    # Helper function to evalueate the low level ssl option
    def faraday_ssl(options)
      return options[:ssl] if options[:ssl]

      ssl = options[:options]
      return unless ssl[:verify_ssl] || ssl[:ssl_cert_store]

      {
        verify: ssl[:verify_ssl] != OpenSSL::SSL::VERIFY_NONE,
        cert_store: ssl[:ssl_cert_store],
      }
    end

    # Helper function to evalueate the low level headers option
    def faraday_headers(options)
      return options[:headers] if options[:headers]

      headers = options[:credentials]
      return unless headers && headers[:token]

      {
        Authorization: "Bearer #{headers[:token]}",
      }
    end

    # Helper function to evalueate the low level headers option
    def faraday_request(options)
      return options[:request] if options[:request]

      request = options[:options]
      return unless request[:open_timeout] || request[:timeout]

      {
        open_timeout: request[:open_timeout],
        timeout: request[:timeout],
      }
    end

    # Helper function to create the args for the low level client
    def faraday_options(options)
      {
        url: options[:url] + options[:path],
        proxy: faraday_proxy(options),
        ssl: faraday_ssl(options),
        headers: faraday_headers(options),
        request: faraday_request(options),
      }
    end
  end
end
