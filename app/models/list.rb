# frozen_string_literal: true

class List < ApplicationRecord
  self.table_name = 'ls_list'

  include SoftDelete
  include Referenceable
  include Tagable
  include Api::Serializable

  ThinkingSphinx::Callbacks.append(self, :behaviours => [:sql, :deltas])

  IGNORE_FIELDS = %i[is_admin is_featured last_user_id delta access featured_list_id].freeze

  has_paper_trail ignore: IGNORE_FIELDS, on: %i[create destroy update]

  belongs_to :user, foreign_key: 'creator_user_id', inverse_of: :lists, optional: true

  has_many :list_entities, inverse_of: :list, dependent: :destroy
  has_many :entities, through: :list_entities
  has_many :images, through: :entities

  validates :name, presence: true
  validates :short_description, length: { maximum: 255 }

  scope :public_scope, -> { where("access <> #{Permissions::ACCESS_PRIVATE}") }
  scope :private_scope, -> { where(access: Permissions::ACCESS_PRIVATE) }
  scope :open_scope, -> { where(access: Permissions::ACCESS_OPEN) }

  def self.viewable(user)
    if user
      public_scope.or(user.lists).order_by_entity_count.order_by_user(user)
    else
      public_scope
    end
  end

  def self.editable(user)
    if user&.has_ability?(:list)
      open_scope.or(user.lists).order_by_entity_count.order_by_user(user)
    else
      none
    end
  end

  def self.featured
    where(is_featured: true)
  end

  def self.order_by_entity_count
    order(entity_count: :desc)
  end

  def self.order_by_user(user)
    order(Arel.sql("ls_list.creator_user_id = #{user.id} DESC, ls_list.updated_at DESC"))
  end

  def self.force_reorder(sort_by = nil, order = nil)
    if sort_by && order
      reorder(sort_by => order)
    else
      current_scope
    end
  end

  def self.reference_optional?
    @reference_optional = true
  end

  def destroy
    soft_delete
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def restricted?
    is_admin || access == Permissions::ACCESS_PRIVATE
  end

  def user_can_access?(user_or_id = nil)
    return true unless access == Permissions::ACCESS_PRIVATE
    user = nil if user_or_id.nil?
    user = User.find_by_id(user_or_id) if user_or_id.is_a? Integer
    user = user_or_id if user_or_id.is_a? User
    return false if user.nil?
    user.permissions.list_permissions(self)[:viewable]
  end

  def user_can_edit?(user = nil)
    return false if user.nil?
    user.permissions.list_permissions(self)[:editable]
  end

  def entities_with_couples
    # if entity on list is couple, replace it with individual entities
    entity_ids = list_entities.joins("LEFT JOIN couple ON (couple.entity_id = ls_list_entity.entity_id)").select("IF(couple.id IS NULL, ls_list_entity.entity_id, NULL) AS entity_id, couple.partner1_id, couple.partner2_id").reduce([]) { |ary, row| ary.concat([row['entity_id'], row['partner1_id'], row['partner2_id']]) }.uniq.compact
    Entity.where(id: entity_ids)
  end

  def interlocks_hash
    list_entities = ListEntity.joins(:list).where(entity_id: entity_ids, ls_list: { is_deleted: false, is_admin: false }).where.not(list_id: id).limit(50000)
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
    select = (!!options[:count] ? "entities.id" : "entities.*") + ", COUNT(DISTINCT e1.id) AS num_entities, STRING_AGG(DISTINCT e1.id::text, ',') AS degree1_ids, SUM(DISTINCT relationships.amount) AS total_amount"
    query = Entity.select(select)
              .joins("LEFT JOIN links ON (links.entity1_id = entities.id)")
              .joins("LEFT JOIN relationships ON (relationships.id = links.relationship_id)")
              .joins("LEFT JOIN entities e1 ON (e1.id = links.entity2_id)")
              .joins("LEFT JOIN ls_list_entity le ON (le.entity_id = e1.id)")
              .joins("LEFT JOIN extension_records er ON (er.entity_id = entities.id)")
              .joins("LEFT JOIN extension_definitions ed ON (ed.id = er.definition_id)")
              .where("entities.is_deleted IS FALSE AND e1.is_deleted IS FALSE")
              .where("le.list_id = #{id}")
              .where("links.category_id IN (#{options[:category_ids].join(', ')})")
              .group("entities.id")
              .order((options[:sort] == :num ? "num_entities" : "total_amount") + " DESC")
    query = query.where("links.is_reverse IS #{options[:order] == 2 ? 'TRUE' : 'FALSE'}") unless options[:order].nil?
    query = query.having("STRING_AGG(DISTINCT ed.name, ',') LIKE '%,#{options[:degree2_type]},%'") unless options[:degree2_type].nil?
    query = query.where("e1.primary_ext = '#{options[:degree1_ext]}'") unless options[:degree1_ext].nil?
    options[:exclude_degree2_types].to_a.each do |type|
      query = query.having("STRING_AGG(DISTINCT ed.name, ',') NOT LIKE '%,#{type},%'")
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

  # [Entity|Ids]
  def add_entities(entities_or_ids)
    entities_or_ids.each { |x| add_one_entity(x) }
    touch
    self
  end

  def add_entity(entity_or_id)
    add_one_entity(entity_or_id)
    touch
    self
  end

  private

  def add_one_entity(entity_or_id)
    ListEntity.find_or_create_by(list_id: id, entity_id: Entity.entity_id_for(entity_or_id))
  end
end
