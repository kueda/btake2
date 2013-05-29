require 'net/http'
require 'uri'
require 'timeout'
require 'rubygems'

class Bee
  ENDPOINT = 'http://ecoengine.berkeley.edu/api'
  SERVICE_VERSION = 1

  def initialize(options = {})
    @service_name = 'Web Service'
    @timeout ||= 5
    @method_param ||= 'function'
    @default_params = {:format => 'json'}
    # @debug = options[:debug]
    @debug = true
  end
  
  def request(method, params = {})
    params      = params.merge(@default_params)
    uri = if params.blank?
      "#{ENDPOINT}/#{method}"
    else
      params_s    = "?" + params.map {|k,v| "#{k}=#{v}"}.join('&')
      [ENDPOINT, method, params_s].join('/')
    end
    request_url(uri)
  end

  def request_url(url)
    request_uri = URI.parse(URI.escape(url))
    response = nil
    begin
      timed_out = Timeout::timeout(@timeout) do
        response = Net::HTTP.start(request_uri.host) do |http|
          puts "MetaService getting #{request_uri.host}#{request_uri.path}?#{request_uri.query}" if @debug
          http.get("#{request_uri.path}?#{request_uri.query}", 
            'User-Agent' => "#{self.class}/#{SERVICE_VERSION}", 
            'Content-Type' => 'application/json',
            'Accept' => 'application/json')
        end
      end
    rescue Timeout::Error
      raise Timeout::Error, "#{@service_name} didn't respond within #{@timeout} seconds."
    end
    puts "response.body: #{response.body}"
    JSON.parse(response.body)
  end

  def method_missing(method, *args)
    request(method, *args)
  end

  def photo(id)
    params_s = @default_params.map {|k,v| "#{k}=#{v}"}.join('&')
    url = [ENDPOINT, 'photos', id, "?#{params_s}"].join('/')
    request_url(url)
  end

  def self.method_missing(method, *args)
    @@bee ||= self.new
    @@bee.send(method, *args)
  end
end
