# frozen_string_literal: true

class Entity < ApplicationRecord
  include SingularTable
  include SoftDelete
  include Referenceable
  include Political
  include Api::Serializable
  include EntityPaths
  include Tagable
  include NetworkAnalysis::EntityInterlocks
  include Pagination
  include EntityExtensions
  # self.default_timezone = :local
  # self.skip_time_zone_conversion_for_attributes = [:created_at, :updated_at]

  ThinkingSphinx::Callbacks.append(self, :behaviours => [:sql, :deltas])

  EXCERPT_SIZE = 150
  PER_PAGE = 20
  BULK_LIMIT = 10
  SORTABLE_ATTRIBUTES = %i[link_count total_usd_donations].freeze

  has_paper_trail :ignore => [:link_count, :delta, :last_user_id],
                  :on =>  [:create, :destroy, :update],
                  :meta => {
                    :entity1_id => :id,
                    :association_data => proc { |e|
                      e.get_association_data.to_yaml if e.paper_trail_event == 'soft_delete'
                    }
                  }

  has_many :aliases, inverse_of: :entity, dependent: :destroy
  has_many :images, inverse_of: :entity, dependent: :destroy
  has_many :list_entities, inverse_of: :entity, dependent: :destroy
  has_many :lists, through: :list_entities

  # links and relationships
  has_many :links, foreign_key: 'entity1_id', inverse_of: :entity, dependent: :destroy
  has_many :reverse_links, class_name: 'Link', foreign_key: 'entity2_id', inverse_of: :related, dependent: :destroy

  has_many :relationships, through: :links

  has_many :hierarchy_relationships,
           -> { where(category_id: Relationship::HIERARCHY_CATEGORY) },
           source: 'relationship',
           through: :links

  has_many :relateds, -> { distinct }, through: :links

  belongs_to :last_user,
             class_name: 'User',
             foreign_key: 'last_user_id',
             inverse_of: :edited_entities,
             optional: true

  belongs_to :parent, class_name: 'Entity', optional: true, inverse_of: :children
  has_many :children, class_name: 'Entity', foreign_key: :parent_id, inverse_of: :parent

  has_many :extension_records, inverse_of: :entity, dependent: :destroy
  has_many :extension_definitions, through: :extension_records, inverse_of: :entities
  has_many :os_entity_categories, inverse_of: :entity
  has_many :os_categories, through: :os_entity_categories, inverse_of: :entities
  has_many :article_entities, inverse_of: :entity, dependent: :destroy
  has_many :articles, through: :article_entities, inverse_of: :entities

  has_many :external_links, inverse_of: :entity, dependent: :destroy do
    ExternalLink::LINK_TYPES.keys.each do |link_type|
      define_method "#{link_type}_link" do
        public_send(link_type).try(:first)
      end

      define_method "#{link_type}_link_value" do
        public_send("#{link_type}_link")&.link_id
      end
    end

    # def cik
    #   sec_link&.link_id
    # end
  end

  # Extensions
  # see concerns/entity_extensions

  # cmp
  has_one :cmp_entity, inverse_of: :entity, dependent: :destroy

  # Legacy Contact
  has_many :addresses, class_name: 'LegacyAddress', inverse_of: :entity, dependent: :destroy
  has_many :phones, inverse_of: :entity, dependent: :destroy
  has_many :emails, inverse_of: :entity, dependent: :destroy

  # Location and Address
  has_many :locations, inverse_of: :entity, dependent: :destroy

  # OpenSecrets
  has_many :matched_contributions, class_name: 'OsMatch', inverse_of: :donor, foreign_key: 'donor_id'
  has_many :contributions, through: :matched_contributions, source: :os_donation
  has_many :donors, class_name: 'OsMatch', inverse_of: :recipient, foreign_key: 'recip_id'
  has_many :committee_donors, class_name: 'OsMatch', inverse_of: :committee, foreign_key: 'cmte_id'

  # NY Election
  has_many :ny_filer_entities
  has_many :ny_filers, through: :ny_filer_entities

  # SCOPES
  scope :people, -> { where(primary_ext: 'Person') }
  scope :orgs, -> { where(primary_ext: 'Org') }
  scope :profile_scope, -> { includes(:aliases, list_entities: [:list]) }

  validates :primary_ext, presence: true
  validates :name, presence: true, entity_name: true
  validates :blurb, length: { maximum: 200 }
  validates :start_date, length: { maximum: 10 }, date: true
  validates :end_date, length: { maximum: 10 }, date: true

  before_validation :trim_name_whitespace, :set_last_user_id
  after_create :create_primary_alias, :create_primary_ext

  ##
  # aliases
  #

  # creates primary alias if the enertity does not have one
  def create_primary_alias
    return nil if aliases.where(is_primary: true).count.positive?

    Alias.without_versioning do
      a = Alias.new(entity: self, name: name, is_primary: true)
      a.skip_update_entity_callback = true
      a.save
    end
  end

  # retrives the primary alias -> <Alias>
  def primary_alias
    aliases.find_by_is_primary(true)
  end

  def also_known_as
    aliases.where(is_primary: false).map(&:name)
  end

  def name_variations
    if org?
      org.name_variations
    elsif person?
      person.name_variations
    end
  end

  def to_param
    # return nil unless persisted?
    "#{id}-#{self.class.parameterize_name(name)}"
  end

  # attributes
  # see concers/entity_extensions for more related functions

  def all_attributes
    attributes.merge!(extension_attributes) #.reject { |k,v| v.nil? }
  end

  def set_attribute(key, value)
    if has_attribute?(key)
      update_attirbute(key.to_sym, value)
    else
      extensions_with_attributes.each do |ext, hash|
        if hash.has_key?(key)
          ext.constantize.find_by(entity_id: id).update_attribute(key, value)
          break
        end
      end
    end
  end

  # Returns a hash representation of the entity
  # options:
  #    url - Adds "url" field (default: true)
  #    all_attributes - includes extensions attributes (default: false)
  #    image_url - includes featured_image_url (default: false)
  #    image_url_type - default: nil
  #    except - excludes these fields( default: ['delta', 'last_user_id']
  # returns HashWithIndifferentAccess
  def to_hash(options = {})
    options = options.with_indifferent_access
                .reverse_merge(url: true,
                               all_attributes: false,
                               image_url: false,
                               image_url_type: nil,
                               except: %w[delta last_user_id])

    hash = send(options[:all_attributes] ? :all_attributes : :attributes).with_indifferent_access
    hash[:url] = url if options[:url]
    hash[:image_url] = featured_image_url(options[:image_url_type]) if options[:image_url]
    hash.except!(*options[:except])
  end

  def parent?
    children.present?
  end

  def child?
    parent.present?
  end

  def has_featured_image
    featured_image.present?
  end

  def featured_image
    @featured_image ||= images.featured.first
  end

  def featured_image_url(type = nil)
    return unless has_featured_image

    type = (featured_image.has_square ? 'square' : 'profile') if type.nil?
    featured_image.image_url(type)
  end

  def featured_image_path(type = nil)
    return unless has_featured_image

    type = (featured_image.has_square ? 'square' : 'profile') if type.nil?
    featured_image.image_path(type)
  end

  def featured_image_source_url
    featured_image&.url
  end

  def add_image_from_url(url, force_featured = false, caption = nil)
    return if images.find { |i| i.url == url }

    image = Image.new_from_url(url)
    return false unless image

    image.title = name
    image.caption = caption
    images << image
    image.feature if force_featured or !has_featured_image
    image
  end

  ##
  # interlocks
  #

  # determines if the entity has a relationship with another entity
  # Entity | Integer --> Boolean
  def connected_to?(other_entity)
    Link.exists?(entity1_id: id, entity2_id: Entity.entity_id_for(other_entity))
  end

  def relateds_by_count(num: 5, primary_ext: nil)
    base = if primary_ext
             relateds.where('entity.primary_ext' => primary_ext)
           else
             relateds
           end

    Entity.where(
      :id => base.select('links.entity2_id, count(*) as c').group('links.entity2_id').order('c desc').limit(num).map { |x| x['entity2_id'] }
    )
  end

  def interlocks_by_count(options={}, only_count=false)
    order1 = options[:order1]
    order2 = options[:order2]
    cat1_ids = options[:cat1_ids]
    cat2_ids = options[:cat2_ids]
    ext2_ids = options[:ext2_ids]
    past1 = options[:past1]
    past2 = options[:past2]
    num = options[:num] || 20
    max_num = options[:max_num]
    page = options[:page]

    r = Link.select("links2.entity2_id AS degree2_id, array_to_string(array_agg(DISTINCT links2.entity1_id), ',') AS degree1_ids, COUNT(DISTINCT links2.entity1_id) AS num")
          .joins("LEFT JOIN links AS links2 ON links.entity2_id = links2.entity1_id")
          .where("links.entity1_id = ?", id)
          .where("links2.entity2_id <> ?", id)
          .group("links2.entity2_id")
          .order("num DESC")

    r = r.where("links.is_reverse = ?", (order1 == 2)) if order1.present?
    r = r.where("links2.is_reverse = ?", (order2 == 2)) if order2.present?

    r = r.where("links.category_id" => cat1_ids) if cat1_ids.present?
    r = r.where("links2.category_id" => cat2_ids) if cat2_ids.present?

    if ext2_ids.present?
      r = r.joins("LEFT JOIN entity e ON e.id = links2.entity2_id LEFT JOIN extension_record er ON er.entity_id = e.id")
      r = r.where("er.definition_id" => ext2_ids)
    end

    if past1.present?
      r = r.joins("LEFT JOIN relationship r1 ON r1.id = links.relationship_id")
      r = r.where("(r1.is_current = 1 OR r1.is_current IS NULL) AND r1.end_date IS NULL")
    end

    if past2.present?
      r = r.joins("LEFT JOIN relationship r2 ON r2.id = links2.relationship_id")
      r = r.where("(r2.is_current = 1 OR r2.is_current IS NULL) AND r2.end_date IS NULL")
    end

    if only_count
      r = r.select("COUNT(DISTINCT l2.entity2_id)")
      r = r.group(nil)
      r = r.order(nil)
    else
      num = [num, max_num].min if max_num.present?
      r = r.limit(num) if num.present?
      r = r.offset(num * (page-1)) if page.present?
    end

    return r.first if only_count

    entities = r.to_a.collect do |row|
      entity = Entity.find_by_id(row[:degree2_id])
      if entity.nil?
        nil
      else
        { entity: entity, degree1_num: row[:num], degree1_ids: row[:degree1_ids] }
      end
    end.compact

    entities
  end

  def self.interlock_ids(entity1_id, entity2_id)
    related_ids = Link.where(entity1_id: entity1_id).pluck(:entity2_id).uniq
    Link.where(entity1_id: entity2_id, entity2_id: related_ids).pluck(:entity2_id).uniq - [entity1_id, entity2_id].map(&:to_i)
  end

  # Utilities - Class Methods #

  # A type checker for definition id and names
  # input: String or Integer
  # output: String or throws ArgumentError
  def self.ext_name_or_id_to_name(name_or_id)
    case name_or_id
    when String
      return name_or_id if all_extension_names.include?(name_or_id)
      raise ArgumentError, "there are no extensions associated with name: #{name_or_id}"
    when Integer
      name = all_extension_names[name_or_id]
      return name unless name.nil?
      raise ArgumentError, "there is no extension associated with id #{name_or_id}"
    else
      raise ArgumentError, "input must be a string or an integer"
    end
  end

  def self.rubin # :)
    find(1164)
  end

  # Input: <Entity> | String | Integer
  # Output: Integer
  def self.entity_id_for(entity)
    raise ArgumentError if entity.nil? || entity == 0

    entity.is_a?(Entity) ? entity.id : entity.to_i
  end

  # Input: <Entity> | String | Integer
  # Output: Entity
  def self.entity_for(entity_or_id)
    return entity_or_id if entity_or_id.is_a? Entity
    return Entity.find(entity_or_id.to_i) if entity_or_id.is_a?(String) || entity_or_id.is_a?(Integer)
    raise ArgumentError, "Accepted types: Entity, Integer, or String"
  end

  def self.with_relationships
    joins(:relationships).having('COUNT(relationship.id) > 0').group('entity.id')
  end

  # Utilities - Instance Methods #

  def update_link_count
    update(link_count: links.count)
  end

  # Formats entity as "Name (id)"
  def name_with_id
    "#{name} (#{persisted? ? id : '?'})"
  end

  def name_without_initials
    name.gsub('.', '').split(' ').select { |part| part.length > 1 }.join(' ')
  end

  def affiliations
    relateds.where('links.category_id IN (1, 3)')
  end

  def industries
    os_categories.map(&:industry_name).uniq
  end

  def add_region(region)
    unless Location.regions.key?(region) || Location.regions.values.include?(region)
      raise ArgumentError, "invalid region: #{region}"
    end

    locations.create!(region: region) unless locations.exists?(region: region)
  end

  def remove_region(region)
    unless Location.regions.key?(region) || Location.regions.values.include?(region)
      raise ArgumentError, "invalid region: #{region}"
    end

    if (location_for_region = locations.find_by(region: region))
      if location_for_region.address
        Rails.logger.warn "cannot remove location with address for #{name_with_id}."
      else
        location_for_region.destroy
      end
    end
  end

  def regions
    locations.pluck(:region)
  end

  def primary_region
    locations.order(region: :asc).pick(:region)
  end

  def region_numbers
    regions.map { |r| Location.regions[r] }
  end

  def add_regions(*regions)
    regions.each(&method(:add_region))
  end

  def remove_regions(*regions)
    regions.each(&method(:remove_region))
  end

  ##
  # User-related methods
  #

  # This update the timestamps and last_user_id as needed.
  # valid inputs:
  #   - string/integer of the user id
  #   - User
  # If input is any other class it will default to using the default 'system' user
  def update_timestamp_for(input)
    touch_by(input)
    self
  end

  ##
  # Couple
  #

  def self.create_couple(name, partner1, partner2)
    blurb = [partner1.blurb, partner2.blurb].compact.join('; ')
    blurb = nil unless blurb.present?

    e = create(
      name: name,
      blurb: blurb,
      primary_ext: 'Couple',
      last_user_id: APP_CONFIG['system_user_id']
    )
    e.couple.partner1_id = partner1.id
    e.couple.partner2_id = partner2.id
    e.couple.save
    e
  end

  def self.find_couple(partner1_id, partner2_id)
    joins(:couple).where("(couple.partner1_id = ? AND couple.partner2_id = ?) OR (couple.partner1_id = ? AND couple.partner2_id = ?)", partner1_id, partner2_id, partner2_id, partner1_id).first
  end

  def couples
    Couple.where("couple.partner1_id = ? OR couple.partner2_id = ?", id, id)
  end

  def partners
    couples.map { |c| c.partner1_id == id ? c.partner2 : c.partner1 }
  end

  ##
  # articles, addresses, references
  #

  # Returns all associated references and references for all relationships the entity is in
  def all_references
    Reference.all_entity_references(self)
  end

  def featured_articles
    articles.where(article_entities: { is_featured: true} )
  end

  def add_article(hash, featured=true)
    article_entity = nil

    ApplicationRecord.transaction do
      article = Article.create(hash)
      article_entity = ArticleEntity.create(
        article_id: article.id,
        entity_id: id,
        is_featured: featured
      )
    end

    article_entity
  end

  def party_members
    Entity.joins(:person).where(person: { party_id: id})
  end

  def unique_addresses
    # returns addresses without geocoding and the most recent address per unique lonlat
    index = {}
    adrs = addresses.order("created_at DESC")
    nils = adrs.select { |a| a.latitude.nil? or a.longitude.nil? }
    adrs.select { |a| a.latitude.present? and a.longitude.present? }.each do |a|
      hash = a.latitude.to_s[0..5] + "," + a.longitude.to_s[0..5]
      next if index[hash].present?
      index[hash] = a
    end

    index.values.concat(nils)
  end

  def total_usd_donations
    relationships
      .where(category_id: Relationship::DONATION_CATEGORY, currency: 'usd')
      .sum(:amount)
  end

  ##
  # View Helpers
  # TODO: Move these to a presenter
  #

  def description
    blurb
  end

  def summary_excerpt
    return nil if summary.nil?
    return summary if summary.length <= EXCERPT_SIZE

    if summary.slice(0, EXCERPT_SIZE).include? "\n"
      return summary.slice(0, summary.index("\n")) + '...'
    end

    summary.truncate(EXCERPT_SIZE, separator: ' ')
  end

  def in_cmp_strata?
    !cmp_entity&.strata.nil?
  end

  # returns hash of basc info for the given entity
  def basic_info
    info = {}
    info[:types] = types.join(', ')
    if person?
      info[:gender] = person.gender if person.gender_id.present?
      info[:birthday] = LsDate.new(start_date).basic_info_display unless start_date.nil?
      info[:date_of_death] = LsDate.new(end_date).basic_info_display unless end_date.nil?
    end
    if org?
      info[:start_date] = LsDate.new(start_date).basic_info_display unless start_date.nil?
      info[:end_date] = LsDate.new(end_date).basic_info_display unless end_date.nil?
      info[:revenue] = ActiveSupport::NumberHelper.number_to_human(org.revenue) unless org.revenue.blank?
    end
    info[:website] = website if website.present?
    info[:aliases] = also_known_as.join(', ') unless also_known_as.empty?
    info[:region] = primary_region if primary_region

    info
  end

  def url
    ApplicationController.helpers.concretize_entity_url(self)
  end

  ##
  # Merging, and history History
  #

  class EntityDeleted < Exceptions::ModelIsDeletedError
  end

  # When an entity is deleted we will store information
  # from it's associated models that gets deleted
  # in a 'meta' field with the PaperTrail version
  def get_association_data
    {
      'extension_ids' => extension_ids,
      'relationship_ids' => relationship_ids,
      'aliases' => aliases.where(is_primary: false).map(&:name),
      'tags' => tags.map(&:name)
    }
  end

  # un-deletes an entity
  # Essentially this just reverts
  # what happens in #after_soft_delete
  def restore!(restore_relationships = false)
    raise Exceptions::CannotRestoreError unless is_deleted

    association_data = retrieve_deleted_association_data
    raise Exceptions::MissingEntityAssociationDataError if association_data.nil?

    create_primary_ext
    create_primary_alias
    add_extensions_by_def_ids(association_data['extension_ids'])
    association_data['aliases'].each do |name|
      aliases.create(name: name, is_primary: false)
    end

    association_data['tags'].each { |tag_name| add_tag_without_callbacks(tag_name) }
    Image.unscoped.where(entity_id: self.id).update_all(is_deleted: false)

    update(is_deleted: false)

    if restore_relationships
      association_data['relationship_ids'].each do |rel_id|
        Relationship.unscoped.find(rel_id).restore!
      end
    end
  end

  def slug
    "/#{primary_ext.downcase}/#{to_param}"
  end

  # MERGING --v
  # TODO: extract these 4 methods into a concern?

  def merge_with(dest)
    EntityMerger.new(source: self, dest: dest).merge!
  end

  # Similar to find() except raises Exceptions::MergedEntityError instead of
  # ActiveRecord::RecordNotFound when the entity is merged and deleted.
  def self.find_with_merges(id:, skope: :itself)
    unscoped.send(skope).find_by(id: id).tap do |e|
      if e&.has_merges?
        raise Exceptions::MergedEntityError.new(e.resolve_merges(skope))
      elsif e.nil? || e&.is_deleted?
        raise ActiveRecord::RecordNotFound
      end
    end
  end

  # Similar to find() except returns the final merged entity if it exists
  def self.find_with_resolved_merge(id:, skope: :itself)
    unscoped.send(skope).find(id).resolve_merges!
  end

  # ?Symbol -> Entity
  def resolve_merges(skope = :itself)
    if has_merges?
      Entity.unscoped.send(skope).find_by(id: merged_id).resolve_merges(skope)
    else
      self
    end
  end

  def resolve_merges!(skope = :itself)
    resolve_merges(skope).tap do |e|
      raise ActiveRecord::RecordNotFound if e.is_deleted?
    end
  end

  def has_merges?
    merged_id.present?
  end

  # ^-- MERGING

  def network_map_collection
    @network_map_collection ||= EntityNetworkMapCollection.new(self)
  end

  #########
  # Search
  ########

  def similar_entities(per_page = 5)
    @similar_entities ||= SimilarEntitiesService
                            .new(self, per_page: per_page)
                            .similar_entities
  end

  def generate_search_terms
    search_terms = aliases.map(&:name)

    search_terms << "*#{name}*"

    if person?
      search_terms << "#{person.name_first} #{person.name_last}"
      search_terms << "#{person.name_first} * #{person.name_last}"
    elsif org?
      org.name_variations.map { |n| OrgName.essential_words(n).join(' ') }.filter(&:present?).each do |x|
        search_terms << x
      end
    end

    search_terms
      .uniq
      .reject(&:blank?)
      .map { |term| ThinkingSphinx::Query.escape(term) }
      .map { |term| "(#{term})" }
      .join(' | ')
  end

  def featured_lists
    lists.where(is_featured: true)
  end

  private

  # Callbacks for Soft Delete
  def after_soft_delete
    Alias.without_versioning { aliases.destroy_all }
    extension_models.each(&:destroy)
    extension_records.destroy_all
    images.each(&:soft_delete)
    list_entities.each(&:destroy)
    relationships.each(&:soft_delete)
    taggings.destroy_all
    PendingEntityRequestResolver.new(self).run
  end

  def name_or_id_to_name(name_or_id)
    self.class.send(:ext_name_or_id_to_name, name_or_id)
  end

  def trim_name_whitespace
    self.name = self.name.strip unless self.name.nil?
  end
end
