class List < ActiveRecord::Base
  self.table_name = "ls_list"

  include SoftDelete
  include Cacheable
  include Referenceable

  has_many :list_entities, inverse_of: :list, dependent: :destroy
  has_many :entities, through: :list_entities
  has_many :images, through: :entities

  has_many :users, inverse_of: :default_network
  has_many :default_groups, inverse_of: :default_network
  has_many :featured_in_groups, class_name: "Group", inverse_of: :featured_list

  has_many :group_lists, inverse_of: :list
  has_many :groups, through: :group_lists, inverse_of: :lists

  has_many :note_lists, inverse_of: :list
  has_many :notes, through: :note_lists, inverse_of: :lists

  has_many :note_networks, inverse_of: :network
  has_many :network_notes, through: :note_networks, inverse_of: :networks

  has_many :sf_guard_group_lists, inverse_of: :list, dependent: :destroy
  has_many :sf_guard_groups, through: :sf_guard_group_lists, inverse_of: :lists

  has_many :topic_lists, inverse_of: :list
  has_many :topics, through: :topic_lists, inverse_of: :lists
  has_one :default_topic, class_name: 'Topic', inverse_of: :default_list, foreign_key: 'default_list_id'

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def network?
  	@is_network
  end

  def name_to_legacy_slug
    name.gsub(" ", "_").gsub("/", "~").gsub('+', '_')
  end

  def legacy_url(action = nil)
    url = "/list/" + id.to_s + "/" + name_to_legacy_slug
    url += "/" + action if action.present?
    url
  end

  def legacy_network_url
    "/#{display_name}"
  end

  def entities_with_couples
    # if entity on list is couple, replace it with individual entities
    entity_ids = list_entities.joins("LEFT JOIN couple ON (couple.entity_id = ls_list_entity.entity_id)").select("IF(couple.id IS NULL, ls_list_entity.entity_id, NULL) AS entity_id, couple.partner1_id, couple.partner2_id").reduce([]) { |ary, row| ary.concat([row['entity_id'], row['partner1_id'], row['partner2_id']]) }.uniq.compact
    Entity.where(id: entity_ids)
  end

  def interlocks_hash
    list_entities = ListEntity.joins(:list).where(entity_id: entity_ids, is_deleted: false, ls_list: { is_network: false, is_deleted: false, is_admin: false }).where.not(list_id: id).limit(50000)
    list_entities.reduce({}) do |hash, le| 
      hash[le.list_id] = hash.fetch(le.list_id, []).push(le.entity_id).uniq
      hash
    end
  end
end