# frozen_string_literal: true

# Simple queue using redis
# Essentially, it's a redis-backed wrapper around of ruby array

# API:
#  get  --> returns first item in queue
#  drop --> returns first item and removes it from queue
#  random_get / random_drop --> same as get/drop, but picks random value
#  remove --> remove item (if it exists) from the queue
#  add(uniq: false)  --> adds item to the queue
#  reset  --> reset the queue
class RedisQueue
  def initialize(name:, reset: nil, options: {})
    @cache_key = "queue/#{name}"
    @reset = reset
    @options = options
  end

  def get
  end

  def drop
  end

  def random_get
  end

  def random_drop
  end

  def add(uniq: false)
  end

  def remove
  end

  def clear
  end

  def empty?
    # fetch.empty?
  end

  def size
    # fetch.size
  end

  def reset
    raise NotImplementedError if reset.nil?

    Rails.cache.fetch(@cache_key, **@options, force: true) do
      reset.call
    end
  end

  private

  def fetch
    # Rails.cache.fetch(@cache_key)
  end
end
