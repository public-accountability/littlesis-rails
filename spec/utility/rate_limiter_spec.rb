describe RateLimiter do
  let(:cache_key) { Faker::Internet.uuid }

  specify do
    RateLimiter.rate_limit(cache_key)
    expect(Rails.cache.read(cache_key)).to eq 1
    RateLimiter.rate_limit(cache_key)
    expect(Rails.cache.read(cache_key)).to eq 2
    expect { RateLimiter.rate_limit(cache_key, limit: 2) }
      .to raise_error(Exceptions::RateLimitExceededError)
  end
end
