# frozen_string_literal: true

# Wrapper around ruby's net/http for JSON.
# Assumes both the content of the request and the server response is JSON.
class JSONRequest
  # Creates new JSON request client
  # @param modify_request [Proc, nil]
  def initialize(modify_request: nil)
    @modify_request = modify_request
  end

  # Performs an HTTP GET request
  # @param url [String]
  # @param query [String, Nil]
  # @return [Hash]
  def get(url, query = nil)
    uri = URI.parse(url)
    uri.query = query if query
    http(uri, create_request(uri, :Get))
  end

  # Performs an HTTP POST request
  # @param url [String]
  # @param data [String, #to_json]
  # @return [Hash]
  def post(url, data)
    uri = URI.parse(url)
    req = create_request(uri, :Post)
    req.body = data.to_json
    http(uri, req)
  end

  # Performs an HTTP put request
  # @param url [String]
  # @param data [String, #to_json]
  # @return [Hash]
  def put(url, data)
    uri = URI.parse(url)
    req = create_request(uri, :Put)
    req.body = data.to_json
    http(uri, req)
  end

  # Performs an HTTP put request
  # @param url [String]
  # @param data [String, #to_json]
  # @return [Hash]
  def delete(url, data = {})
    uri = URI.parse(url)
    req = create_request(uri, :Delete)
    req.body = data.to_json
    http(uri, req)
  end

  private

  # Runs the HTTP request
  # @param uri [URI]
  # @param request [Net::HTTPRequest]
  # @return [Hash]
  def http(uri, request)
    Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
      response = http.request(request)
      if response.is_a? Net::HTTPSuccess
        return JSON.parse(response.body)
      else
        err_message = "Request to #{uri} failed with response code #{response.code}"
        Rails.logger.info err_message
        Rails.logger.info "Failed HTTP response body\n #{response.body}\n" if response.body
        raise Exceptions::HTTPRequestFailedError, err_message
      end
    end
  end

  # Creates a new http request
  # @param uri [URI]
  # @param method [Symbol]
  # @return Net::HTTPRequest
  def create_request(uri, method)
    Net::HTTP.const_get(method).new(uri).tap do |request|
      request['Content-Type'] = 'application/json'
      request['Accept'] = 'application/json'
      @modify_request&.call(request)
    end
  end
end
