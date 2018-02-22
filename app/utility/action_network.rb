##
# Interacts with the action network api
#
module ActionNetwork
  API_KEY = APP_CONFIG.fetch('action_network_api_key').dup.freeze
  API_INFO_URL = 'https://actionnetwork.org/api/v2'.freeze
  PEOPLE_URL = 'https://actionnetwork.org/api/v2/people'.freeze
  TAGS = { signup: 'LS-Signup', newsletter: 'PAI and LittleSis Updates', map_the_power: 'MTP' }.freeze

  # :section: Public API

  # Signs up a user to Action Network
  # If the request is sucussful, it returns +true+.
  # If the requests fails, it returns +false+
  # and sends a warning message to the rails logger.
  #
  # User --> Boolean
  def self.signup(user)
    uri = URI.parse(PEOPLE_URL)
    req = request(uri, :Post)
    req.set_form_data(signup_params(user))
    Rails.logger.debug http(uri, req)
    true
  rescue HTTPRequestFailedError
    Rails.logger.warn "Failed to add user #{user.username}(#{user.id}) to ActionNetwork"
    false
  end

  # Returns list people in ActionNetwork
  def self.people(page = 1)
    uri = URI.parse(PEOPLE_URL)
    req = request(uri, :Get)
    req.set_form_data(page: page)
    http(uri, req)
  end

  # Returns a hash of basic information about ActionNetwork's Api
  # Not that useful in produciton, but helpful in development.
  def self.api_info
    uri = URI.parse(API_INFO_URL)
    http uri, request(uri, :Get)
  end

  # :section: HTTP Helper Functions

  # Generates hash of user infor for submission to action network
  def self.signup_params(user)
    {
      "person" => {
        "identifiers" => [ action_network_identifier(user) ],
        "family_name" => user.name_last,
        "given_name" => user.name_first,
        "email_addresses" => [ { "address" => user.email } ]
      },
      "add_tags" => action_network_tags(user)
    }
  end
  
  # Performs a http request and return response as a hash
  #
  # URI,  Net::HTTP::Get --> Hash
  def self.http(uri, request)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      response = http.request(request)
      return JSON.parse(response.body) if response.is_a? Net::HTTPSuccess
      raise HTTPRequestFailedError, "Response code: #{response.code}"
    end
  end

  # Formats a URI into an http request with correct API Headers
  def self.request(uri, method)
    Net::HTTP.const_get(method).new(uri).tap do |request|
      request["User-Agent"] = "Mozilla/5.0"
      request["Content-Type"] = "application/json"
      request["OSDI-API-Token"] = API_KEY
    end
  end    

  private_class_method def self.action_network_identifier(user)
    "littlesis_user_id:#{user.id}"
  end

  private_class_method def self.action_network_tags(user)
    tags = [ TAGS[:signup] ]
    tags << TAGS[:newsletter] if user.newsletter
    tags << TAGS[:map_the_power] if user.map_the_power
    tags
  end

  # Any failed response, regardless of the status code,
  # will raise this error
  class HTTPRequestFailedError < StandardError
  end
end
