require 'socket'

class LegacyCache
  attr_accessor :client, :host

  def initialize(host)
    @client ||= Dalli::Client.new(Lilsis::APP_CONFIG['legacy_cache_connection'], compress: false, serializer: PhpSerializer)
    @host = host
  end

  def prefix
    Lilsis::Application.config.symfony_path + "/apps/frontend:"
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
    entity = Entity.find(id)
    actions = %w(view relationships leadership board family friends government business otherPositions education fundraising politicalDonors people memberships owners holdings transactions donors recipients lobbying lobbiedBy lobbyingTargets office officeOf image images address network interlocks schools giving funding political references modifications imageModifications imagesModifications relationshipModifications childOrgs lobbyingArmy networkSearch view notes map interlocksMap addRelationship)
    partials = ['_page', '_action', 'leftcol_profileimage', 'leftcol_references', 'leftcol_stats', 'leftcol_lists', 'relationship_tabs_content', 'similarEntities', 'watchers']

    keys = actions.map { |action| partials.map { |partial| "/#{@host.gsub('.', '_')}/all/entity/#{action}/_sf_cache_key/#{partial}/id/#{id}/slug/#{entity.name_to_legacy_slug}" } }.flatten.uniq

    clear_keys(keys)
  end

  def clear_list_cache(id)
    list = List.find(id)
    actions = %w(modifications entityModifications members interlocks business government otherOrgs giving funding images pictures view references notes list map addEntiy list)
    partials = ['_page', '_action']

    keys = actions.map { |action| partials.map { |partial| "/#{@host.gsub('.', '_')}/all/list/#{action}/_sf_cache_key/#{partial}/id/#{id}/slug/#{list.name_to_legacy_slug}" } }.flatten.uniq

    clear_keys(keys)
  end

  def clear_keys(keys)
    keys.each do |key|
      key = prefix + key unless key.match(prefix)
      Rails.logger.debug(key)
      @client.delete(key)
    end
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
