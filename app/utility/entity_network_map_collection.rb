# frozen_string_literal: true

# This stores sets of NetworkMap ids
# in the Rails Cache (redis), so they can
# be easily retrived to display on an entity's
# profile page.
#
#
class EntityNetworkMapCollection
  attr_accessor :maps
  extend Forwardable
  def_delegators :@maps, :each, :map, :size, :sort

  def initialize(entity_or_id)
    @entity_id = Entity.entity_id_for(entity_or_id)
    @cache_key = "entity-#{@entity_id}/networkmaps"
    if cache_exists?
      @maps = cache_read
    else
      @maps = Set.new
    end
  end

  # methods #add and #remove do NOT persist the data
  # #save must be called afterwards.

  def add(network_map_id)
    @maps.add network_map_id
    self
  end

  def remove(network_map_id)
    @maps.delete network_map_id
    self
  end

  def delete
    Rails.cache.delete(@cache_key)
  end

  def save
    if @maps.empty
      delete
    else
      cache_write(@maps)
    end
    self
  end

  ## class methods ##

  def self.remove_all(network_map_id)
  end

  private

  def cache_exists?
    Rails.cache.exist?(@cache_key)
  end

  def cache_read
    Rails.cache.read(@cache_key)
  end

  def cache_write(value)
    Rails.cache.write(@cache_key, value)
  end
end
