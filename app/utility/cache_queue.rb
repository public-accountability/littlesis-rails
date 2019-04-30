# frozen_string_literal: true

# Simple queue stored using Rails's cache
# Essentially, it's a wrapper around a ruby array stored in the cache

class CacheQueue
  attr_reader :cache_key

  def initialize(name:, reset: nil, options: {})
    @cache_key = "queue/#{name}"
    @reset = reset
    @options = options
  end

  delegate :size, to: :fetch
  delegate :empty?, to: :fetch

  def set(value)
    TypeCheck.check value, Array
    write(value)
    self
  end

  def get
    fetch[0]
  end

  def get!
    current_queue = fetch
    return nil if current_queue.blank?

    value = current_queue.slice!(0)
    write(current_queue)
    value
  end

  def random_get
    fetch.sample
  end

  def random_get!
    current_queue = fetch
    return nil if current_queue.blank?

    value = current_queue.slice!(rand(current_queue.size))
    write(current_queue)
    value
  end

  def add(value, uniq: false)
    current_queue = fetch
    write(current_queue << value) unless uniq && current_queue.include?(value)
    self
  end

  def remove(value)
    current_queue = fetch
    write(current_queue) if current_queue.delete(value)
    self
  end

  def clear
    write([])
  end

  def reset
    raise NotImplementedError if @reset.nil?

    write(@reset.call)
    self
  end

  def fetch
    Rails.cache.fetch(@cache_key)
  end

  private

  def write(value)
    Rails.cache.write(@cache_key, value, @options)
  end
end
