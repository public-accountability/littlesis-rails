# frozen_string_literal: true

##
# Interacts with the action network api
# can add users and email address to LittleSis
#
module ActionNetwork
  API_KEY = Rails.application.config.littlesis.fetch(:action_network_api_key).dup.freeze
  API_INFO_URL = 'https://actionnetwork.org/api/v2'
  PEOPLE_URL = 'https://actionnetwork.org/api/v2/people'

  # Tags are primarily how the LittleSis staff
  # organizes and sorts  users on action network
  TAGS = {
    signup: 'LS-Signup',
    newsletter: 'PAI and LittleSis Updates',
    map_the_power: 'MTP',
    pai: 'PAI-Signup',
    press: 'press'
  }.freeze

  # :section: Public API

  # Signs up a user to Action Network
  #
  # User --> Boolean
  def self.signup(user)
    post URI.parse(PEOPLE_URL), signup_params(user)
  end

  # Adds an email address to the LittleSis Newsletter on action network
  #
  # String --> Boolean
  def self.add_email_to_newsletter(email)
    post URI.parse(PEOPLE_URL), email_params(email, :newsletter)
  end

  # Adds an email address to the PAI Newsletter
  #
  # String --> Boolean
  def self.add_email_to_pai(email)
    post URI.parse(PEOPLE_URL), email_params(email, :pai)
  end

  # Adds an email address to the Press List
  #
  # String --> Boolean
  def self.add_email_to_press(email)
    post URI.parse(PEOPLE_URL), email_params(email, :press)
  end

  # Retrieves people from our Action Network Api
  # Int --> Hash
  def self.people(page = 1)
    uri = URI.parse(PEOPLE_URL)
    req = request(uri, :Get)
    req.set_form_data(page: page)
    http(uri, req)
  end

  # Returns a hash of basic information about ActionNetwork's Api
  # Not that useful in production, but helpful in development.
  def self.api_info
    uri = URI.parse(API_INFO_URL)
    http uri, request(uri, :Get)
  end

  # :section: HTTP Helper Functions

  # Generates hash of user information for submission to action network
  # User --> Hash
  def self.signup_params(user)
    {
      'person' => {
        'identifiers' => [action_network_identifier(user)],
        'family_name' => user.name_last,
        'given_name' => user.name_first,
        'email_addresses' => [{ 'address' => user.email }]
      },
      'add_tags' => action_network_tags(user)
    }
  end

  # Generates hash for action network singups
  # for an email address interested in joining the newsletter
  # String, Symbol --> Hash
  def self.email_params(email, tag)
    {
      'person' => {
        'email_addresses' => [{ 'address' => email }]
      },
      'add_tags' => Array.wrap(TAGS.fetch(tag))
    }
  end

  # Posts data to Action Network
  # Suppresses http errors and sends messages to logger
  # If the request is successful, it returns +true+.
  # If the request fails, it returns +false+
  # and sends a warning message to the rails logger.
  #
  # URI, Hash --> Boolean
  def self.post(uri, data)
    req = request(uri, :Post)
    req.body = data.to_json
    Rails.logger.debug http(uri, req)
    true
  rescue HTTPRequestFailedError
    Rails.logger.warn "Post request failed: #{data}"
    false
  end

  # Performs a http request and return response as a hash
  #
  # URI,  Net::HTTP::Get --> Hash | raises HTTPRequestFailedError
  def self.http(uri, request)
    Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
      response = http.request(request)
      if response.is_a? Net::HTTPSuccess
        return JSON.parse(response.body)
      else
        Rails.logger.debug response.body if response.body
        raise HTTPRequestFailedError, "Response code: #{response.code}"
      end
    end
  end

  # Formats a URI into an http request with correct API Headers
  def self.request(uri, method)
    Net::HTTP.const_get(method).new(uri).tap do |request|
      request['User-Agent'] = 'Mozilla/5.0'
      request['Content-Type'] = 'application/json'
      request['OSDI-API-Token'] = API_KEY
    end
  end

  private_class_method def self.action_network_identifier(user)
    "littlesis_user_id:#{user.id}"
  end

  private_class_method def self.action_network_tags(user)
    tags = Array.wrap(TAGS[:signup])
    tags << TAGS[:newsletter] if user.newsletter
    tags << TAGS[:map_the_power] if user.map_the_power
    tags
  end

  # Any failed response, regardless of the status code,
  # will raise this error
  class HTTPRequestFailedError < StandardError
  end
end
