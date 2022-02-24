# frozen_string_literal: true

module ActionNetwork
  API_KEY = Rails.application.config.littlesis.fetch(:action_network_api_key).dup.freeze
  API_INFO_URL = 'https://actionnetwork.org/api/v2'
  PEOPLE_URL = 'https://actionnetwork.org/api/v2/people'
  TAGS_URL = 'https://actionnetwork.org/api/v2/tags'

  # Tags allows us to target emails to specific users
  TAGS = {
    newsletter: {
      name: 'LS-Newsletter',
      id: 'b7c2e8c7-0eda-4eef-a97f-4da9bb1d4da6'
    },
    map_the_power: {
      name: 'MTP',
      id: '0fca0e34-7f87-46e0-bd50-3841c434af46'
    },
    tech: {
      name: "LS-Tech",
      id: '6a10825a-6793-4110-8199-bd6004c3400d'
    }
  }.freeze

  TAGS_BY_ID = TAGS.map { |k, v| [v[:id], k] }.to_h.freeze

  module HTTP
    def self.get(url, query = nil)
      uri = URI.parse(url)
      uri.query = query if query
      http(uri, request(uri, :Get))
    end

    def self.post(url, data)
      uri = URI.parse(url)
      req = request(uri, :Post)
      req.body = data.to_json
      http(uri, req)
    end

    def self.put(url, data)
      uri = URI.parse(url)
      req = request(uri, :Put)
      req.body = data.to_json
      http(uri, req)
    end

    def self.delete(url, data = {})
      uri = URI.parse(url)
      req = request(uri, :Delete)
      req.body = data.to_json
      http(uri, req)
    end

    # URI,  Net::HTTP::Get --> Hash | raises HTTPRequestFailedError
    private_class_method def self.http(uri, request)
      Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
        response = http.request(request)
        if response.is_a? Net::HTTPSuccess
          return JSON.parse(response.body)
        else
          Rails.logger.warn "[ActionNetwork] #{response.body}" if response.body
          raise Exceptions::HTTPRequestFailedError, "Response code: #{response.code}"
        end
      end
    end

    # Formats a URI into an http request with correct API Headers
    # UIR, symbol --> Net::HTTPRequest
    private_class_method def self.request(uri, method)
      Net::HTTP.const_get(method).new(uri).tap do |request|
        request['User-Agent'] = 'Mozilla/5.0'
        request['Content-Type'] = 'application/json'
        request['OSDI-API-Token'] = API_KEY
      end
    end
  end

  class Activist
    attr_reader :email

    def initialize(user_or_email)
      @email = ActionNetwork.email_from_user(user_or_email)
    end

    def tags
      return [] if taggings.nil?

      taggings
        .map { |x| x.dig('_links', 'osdi:tag') }
        .compact
        .map { |t| TAGS_BY_ID.fetch(t['href'].split('/').last, nil) }
        .compact
    end

    def in_action_network?
      info.present?
    end

    def subscribed?
      in_action_network? && info['email_addresses'].first['status'] == 'subscribed'
    end

    def subscribe
      return if subscribed?

      if in_action_network?
        HTTP.put(endpoint,  { "email_addresses" =>  [ { "status" =>  "subscribed" } ] })
      else
        @info = ActionNetwork.signup(@email)
      end
    end

    def unsubscribe
      return unless subscribed?

      HTTP.put(endpoint,  { "email_addresses" =>  [ { "status" =>  "unsubscribed" } ] })
    end

    def add(list)
      raise ArgumentError unless TAGS.keys.include?(list)

      return true if tags.include?(list)

      url = "#{TAGS_URL}/#{TAGS.dig(list, :id)}/taggings"
      data = { '_links' => { 'osdi:person' => endpoint } }
      HTTP.post(url, data)
    end

    def remove(list)
      raise ArgumentError unless TAGS.keys.include?(list)

      return unless tags.include?(list)

      url = taggings
              .find { |tagging| tagging.dig('_links', 'osdi:tag', 'href')&.split('/')&.last == TAGS.fetch(list).fetch(:id) }
              .dig('_links', 'self', 'href')

      HTTP.delete(url)
    end

    private

    def endpoint
      info.dig('_links', 'self', 'href')
    end

    def info
      @info ||= ActionNetwork.find_by_email(@email)
    end

    def taggings
      return nil if info.nil?

      @taggings ||= HTTP
                      .get(info.dig('_links', 'osdi:taggings', 'href'))
                      .dig('_embedded', 'osdi:taggings')
    end
  end

  def self.signup(user_or_email, lists = [:newsletter])
    email = email_from_user(user_or_email)

    data = {
      'person' => {
        'email_addresses' => [{ 'address' => email }],
        'status' => 'subscribed'
      },
      'add_tags' => lists.map { |list| TAGS.fetch(list).fetch(:name) }
    }

    HTTP.post(PEOPLE_URL, data)
  end

  # Retrieves people from our Action Network Api
  # Int --> Hash
  def self.people(page = 1)
    HTTP.get PEOPLE_URL, "page=#{page}"
  end

  # String --> Hash
  def self.find_by_email(email)
    HTTP.get(PEOPLE_URL, "filter=email_address eq '#{email}'").dig('_embedded', 'osdi:people').first
  end

  # Returns a hash of basic information about ActionNetwork's API
  def self.api_info
    HTTP.get(API_INFO_URL)
  end

  def self.email_from_user(user_or_email)
    if user_or_email.is_a?(User)
      user_or_email.email
    elsif user_or_email.is_a?(String) && Devise.email_regexp.match?(user_or_email)
      user_or_email
    else
      raise Exceptions::LittleSisError, "#{user_or_email} is not a User or an email address"
    end
  end
end
