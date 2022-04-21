# frozen_string_literal: true

module RateLimiter
  def self.rate_limit(cache_key, limit: 5, expires_in: 60.minutes)
    if Rails.cache.exist?(cache_key)
      count = Rails.cache.read(cache_key) + 1

      if count > limit
        raise Exceptions::RateLimitExceededError, "#{cache_key} exceeded limit #{limit}."
      else
        Rails.cache.write(cache_key, count, expires_in: expires_in)
        # This implementation is more accurate, but requires the use of `Redis` as opposed to `Rails.cache`
        # ttl = Rails.cache.redis.ttl(cache_key)
        # Rails.cache.write(ip_cache_key, 1, expires_in: ttl.negative? ? expires_in : ttl)
      end
    else
      Rails.cache.write(cache_key, 1, expires_in: expires_in)
    end
  end
end
