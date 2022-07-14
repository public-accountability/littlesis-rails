# frozen_string_literal: true

# Cache-backed confirmation link for newsletter subscriptions
NewslettersConfirmationLink = Struct.new(:email, :tags, :secret, :created_at) do
  def initialize(...)
    super(...)
    freeze
  end

  def cache_key
    "newsletters/confirmation/#{secret}"
  end

  def url
    p, h = Rails.application.routes.default_url_options.values_at(:protocol, :host)
    "#{p}://#{h}/#{cache_key}"
  end

  def expired?
    1.hour.ago > created_at
  end

  # Saves new confirmation link to the cache
  #
  # @param email [String] subscriber's email address
  # @param tags [Array<String>] list of action network tags (i.e. "tech")
  def self.create(email, tags)
    new(email, tags, SecureRandom.hex, Time.current).tap do |link|
      Rails.cache.write(link.cache_key, link.to_a, expires_in: 1.hour)
    end
  end

  # Extracts a Newsletter Confirmation Link from the cache
  #
  # @param secret [String] confirmation secret
  # @return [NewslettersConfirmationLink] the link for the provided secret
  # @return [Nil] if the confirmation does not exist or is expired
  def self.find(secret)
    cache_data = Rails.cache.fetch("newsletters/confirmation/#{secret}")
    if cache_data
      link = NewslettersConfirmationLink.new(*cache_data)
      return link unless link.expired?
    end
  end
end
