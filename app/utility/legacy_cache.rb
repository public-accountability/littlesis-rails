class LegacyCache
  attr_accessor :client

  def initialize
    @client ||= Dalli::Client.new('localhost:11211', compress: false, serializer: PhpSerializer)
  end

  def prefix
    Lilsis::Application.config.symfony_frontend_dir + ":"
  end

  def meta_keys
    @client.get(prefix + '_metakeys').to_a.map { |meta_key| prefix + meta_key }
  end

  def remove_meta_key(key)
    keys = meta_keys
    if keys.include?(key)
      keys.delete(key)
      @client.delete(key)
      @client.replace(prefix + '_metakeys', keys)
    end
  end

  def remove_key_from_meta(key)
    meta_keys.each do |meta_key|
      keys = @client.get(meta_key)
      if keys.include?(key)
        keys.delete(key)
        @client.replace(meta_key, keys)
      end
    end
  end

  def data_keys
    meta_keys.map { |meta_key| @client.get(meta_key) }.flatten.uniq
  end

  def match_keys(pattern)
    data_keys.select { |key| key.match(pattern) }
  end

  def clear_key_pattern(pattern)
    match_keys(pattern).each do |key| 
      remove_key_from_meta(key) if @client.delete(key)
    end
  end

  def clear_entity_cache(id)
    clear_key_pattern(/all\/entity\/.*\/id\/#{id}\//i)
  end
end

class PhpSerializer
  def self.load(value)
    PHP.unserialize(value)
  end

  def self.dump(value)
    PHP.serialize(value)
  end
end