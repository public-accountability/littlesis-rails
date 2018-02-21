module ActionNetwork
  API_KEY = APP_CONFIG.fetch('action_network_api_key').dup.freeze
  API_INFO_URL = 'https://actionnetwork.org/api/v2'.freeze

  def self.api_info
    uri = URI.parse(API_INFO_URL)
    request = Net::HTTP::Get.new uri
    request["User-Agent"] = "Mozilla/5.0"
    request["Content-Type"] = "application/json"
    request["OSDI-API-Token"] = API_KEY

    http(uri, request)
  end

  def self.http(uri, request)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      response = http.request(request)
      return JSON.parse(response.body) if response.is_a? Net::HTTPSuccess
      raise HTTPRequestFailedError, "Response code: #{response.code}"
    end
  end

  class HTTPRequestFailedError < StandardError
  end
end
