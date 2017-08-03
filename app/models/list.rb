class List < ActiveRecord::Base
  self.table_name = "ls_list"

  include SoftDelete
  include Referenceable
  include Tagable

  has_paper_trail
  
  belongs_to :user, foreign_key: "creator_user_id", inverse_of: :lists

  has_many :list_entities, inverse_of: :list, dependent: :destroy
  has_many :entities, through: :list_entities
  has_many :images, through: :entities

  has_many :users, inverse_of: :default_network
  has_many :default_groups, inverse_of: :default_network
  has_many :featured_in_groups, class_name: "Group", inverse_of: :featured_list

  has_many :group_lists, inverse_of: :list
  has_many :groups, through: :group_lists, inverse_of: :lists

  has_many :note_networks, inverse_of: :network
  has_many :network_notes, through: :note_networks, inverse_of: :networks

  has_many :sf_guard_group_lists, inverse_of: :list, dependent: :destroy
  has_many :sf_guard_groups, through: :sf_guard_group_lists, inverse_of: :lists

  has_many :topic_lists, inverse_of: :list
  has_many :topics, through: :topic_lists, inverse_of: :lists
  has_one :default_topic, class_name: 'Topic', inverse_of: :default_list, foreign_key: 'default_list_id'

  validates_presence_of :name
  validates :short_description, length: { maximum: 255 }

  scope :public_scope, -> { where(is_private: false) }
  scope :private_scope, -> { where(is_private: true) }

  def destroy
    soft_delete
  end
  
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

  def user_can_access?(user = nil)
    return true unless is_private?
    user_id = user if user.is_a? Integer
    user_id = user.id if user.is_a? User
    return false unless user_id.present?
    creator_user_id == user_id
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

  def interlocks_count(options)
    interlocks(options.merge(count: true)).map(&:id).count
  end

  def interlocks(options)
    options = { count: false, sort: :num }.merge(options)
    select = (!!options[:count] ? "entity.id" : "entity.*") + ", CONCAT(',', GROUP_CONCAT(DISTINCT ed.name), ',') AS exts, COUNT(DISTINCT e1.id) AS num_entities, GROUP_CONCAT(DISTINCT e1.id) AS degree1_ids, SUM(DISTINCTROW relationship.amount) AS total_amount"
    query = Entity.select(select)
              .joins("LEFT JOIN link ON (link.entity1_id = entity.id)")
              .joins("LEFT JOIN relationship ON (relationship.id = link.relationship_id)")
              .joins("LEFT JOIN entity e1 ON (e1.id = link.entity2_id)")
              .joins("LEFT JOIN ls_list_entity le ON (le.entity_id = e1.id)")
              .joins("LEFT JOIN extension_record er ON (er.entity_id = entity.id)")
              .joins("LEFT JOIN extension_definition ed ON (ed.id = er.definition_id)")
              .where("le.is_deleted = 0 AND entity.is_deleted = 0 AND e1.is_deleted = 0")
              .where("le.list_id = #{id}")
              .where("link.category_id IN (#{options[:category_ids].join(', ')})")
              .group("entity.id")
              .order((options[:sort] == :num ? "num_entities" : "total_amount") + " DESC")
    query = query.where("link.is_reverse = #{options[:order] == 2 ? 1 : 0}") unless options[:order].nil?
    query = query.having("exts LIKE '%,#{options[:degree2_type]},%'") unless options[:degree2_type].nil?
    query = query.where("e1.primary_ext = '#{options[:degree1_ext]}'") unless options[:degree1_ext].nil?
    options[:exclude_degree2_types].to_a.each do |type|
      query = query.having("exts NOT LIKE '%,#{type},%'")
    end

    query
  end

  # The host argument is there for compatibility reasons:
  # the symfony/legacy caching system required it.
  # In Rails, all we need to do to clear the cache
  # is change the updated_at timestamp
  def clear_cache(host = nil)
    touch
  end

  def self.default_network
    find(Lilsis::Application.config.default_network_id)
  end
end
