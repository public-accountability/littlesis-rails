# frozen_string_literal: true

# rubocop:disable Naming/PredicateName, Style/StringLiterals

class Relationship < ApplicationRecord
  include SingularTable
  include SoftDelete
  include Referenceable
  include RelationshipDisplay
  include SimilarRelationships
  include Tagable
  include Api::Serializable

  has_paper_trail :ignore => [:last_user_id],
                  :on => %i[create destroy update],
                  :meta => {
                    :entity1_id => :entity1_id,
                    :entity2_id => :entity2_id,
                    :association_data => proc { |r|
                      r.get_association_data.to_yaml if r.paper_trail_event == 'soft_delete'
                    }
                  }

  POSITION_CATEGORY = 1
  EDUCATION_CATEGORY = 2
  MEMBERSHIP_CATEGORY = 3
  FAMILY_CATEGORY = 4
  DONATION_CATEGORY = 5
  TRANSACTION_CATEGORY = 6
  LOBBYING_CATEGORY = 7
  SOCIAL_CATEGORY = 8
  PROFESSIONAL_CATEGORY = 9
  OWNERSHIP_CATEGORY = 10
  HIERARCHY_CATEGORY = 11
  GENERIC_CATEGORY = 12

  BULK_LIMIT = 8

  ALL_CATEGORIES = [
    '',
    'Position',
    'Education',
    'Membership',
    'Family',
    'Donation',
    'Trans',
    'Lobbying',
    'Social',
    'Professional',
    'Ownership',
    'Hierarchy',
    'Generic'
  ].freeze

  ALL_CATEGORIES_WITH_FIELDS = %w[Position Education Membership Family Donation Trans Ownership].freeze
  ALL_CATEGORY_IDS_WITH_FIELDS = [1, 2, 3, 4, 5, 6, 10].freeze
  TEMPORAL_STATUS_RANK = {
    current: 2,
    unknown: 1,
    past: 0
  }.freeze

  has_many :links, inverse_of: :relationship
  belongs_to :entity, class_name: "Entity", foreign_key: "entity1_id", optional: true
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id", optional: true
  belongs_to :unscoped_entity, -> { unscope(where: :is_deleted) }, foreign_key: "entity1_id", class_name: "Entity", optional: true
  belongs_to :unscoped_related, -> { unscope(where: :is_deleted) }, class_name: "Entity", foreign_key: "entity2_id", optional: true
  has_one :position, inverse_of: :relationship, dependent: :destroy
  has_one :education, inverse_of: :relationship, dependent: :destroy
  has_one :membership, inverse_of: :relationship, dependent: :destroy
  has_one :family, inverse_of: :relationship, dependent: :destroy
  has_one :donation, inverse_of: :relationship, dependent: :destroy
  has_one :trans, class_name: "Transaction", inverse_of: :relationship, dependent: :destroy
  has_one :ownership, inverse_of: :relationship, dependent: :destroy

  accepts_nested_attributes_for :position
  accepts_nested_attributes_for :education
  accepts_nested_attributes_for :membership
  accepts_nested_attributes_for :family
  accepts_nested_attributes_for :donation
  accepts_nested_attributes_for :trans
  accepts_nested_attributes_for :ownership

  belongs_to :category, class_name: "RelationshipCategory", inverse_of: :relationships
  belongs_to :last_user, class_name: "User", foreign_key: "last_user_id", optional: true

  # Open Secrets
  has_many :os_matches, inverse_of: :relationship
  has_many :os_donations, through: :os_matches

  # NY Contributions
  has_many :ny_matches, inverse_of: :relationship
  has_many :ny_disclosures, through: :ny_matches

  # External Data
  # has_many :external_relationships, dependent: :nullify
  # has_many :external_data, through: :external_relationships

  validates :entity1_id, presence: true
  validates :entity2_id, presence: true
  validates :category_id, presence: true
  validates :start_date, length: { maximum: 10 }, date: true
  validates :end_date, length: { maximum: 10 }, date: true
  validates :description1, length: { maximum: 100 }
  validates :description2, length: { maximum: 100 }
  validates_with RelationshipValidator
  validates :currency, presence: { if: -> { amount.present? }, message: 'not specified for amount' }
  validates :currency, absence: { if: -> { amount.blank? }, message: 'entered without an amount' }
  validates :currency, inclusion: {
    in: Money::Currency.table.stringify_keys.keys, message: "%<value>s is not a valid currency code"
  }, if: -> { currency.present? }
  before_validation :set_currency_default

  before_validation :set_last_user_id

  before_save :update_is_current_according_to_end_date

  after_create :after_create_tasks

  # after_commit { Link.refresh }

  # This callback is basically a modified version of :touch => true
  # It updates the entity timestamps and also changes the last_user_id of
  # associated entities for the relationship
  after_save :update_entity_timestamps

  def after_create_tasks
    Link.refresh
    create_category
    update_entity_links
  end

  # called in referenceable#add_reference
  def after_add_reference
    entity.references.find_or_create_by(document_id: @_last_reference.document.id)
    related.references.find_or_create_by(document_id: @_last_reference.document.id)
  end

  # Some relationship categories contain additional fields stored in other tables
  # For instance, when a new donation relationship is created,  this method will create <Donation>.
  # When a generic relationship is created, this method becomes a noop.
  def create_category
    if category_has_fields? && get_category.nil?
      ALL_CATEGORIES
        .fetch(category_id)
        .constantize
        .create(relationship: self)
    end
  end

  private :create_category

  def self.all_categories
    ALL_CATEGORIES
  end

  def self.category_display_name(cat_id)
    return 'Transaction' if cat_id == TRANSACTION_CATEGORY

    ALL_CATEGORIES[cat_id]
  end

  def self.category_hash
    Hash[[*all_categories.map.with_index]].invert.select { |_k, v| v.present? }
  end

  def self.all_categories_with_fields
    ALL_CATEGORIES_WITH_FIELDS
  end

  def self.all_category_ids_with_fields
    ALL_CATEGORY_IDS_WITH_FIELDS
  end

  # Integer -> Array[Symbol] | nil
  # returns list of attributes for categories
  def self.attribute_fields_for(cat_id)
    TypeCheck.check cat_id, Integer
    return nil unless all_category_ids_with_fields.include?(cat_id)

    ALL_CATEGORIES
      .fetch(cat_id)
      .constantize
      .attribute_names
      .map(&:to_sym) - [:id, :relationship_id]
  end

  # This is used by bulk add tool (see tools_helper.rb) to
  # generate the <option> tag for the relationship select.
  # If it's an org it excludes relationship categories that
  # can only occur between two people.
  # Due to the complexities involved, this function excludes
  # lobbying relationships (as does the bulk add tool)
  def self.categories_for(cat)
    if cat == 'Org'
      [1, 2, 3, 5, 6, 10, 11, 12]
    elsif cat == 'Person'
      [1, 2, 3, 4, 5, 6, 8, 9, 10, 11, 12]
    else
      raise ArgumentError, "Input must be 'Org' or 'Person'"
    end
  end

  def category_name
    ALL_CATEGORIES[category_id]
  end

  # same as category_name, except returns "Transaction" instead of Trans
  def category_name_display
    self.class.category_display_name(category_id)
  end

  def all_attributes
    attributes.merge!(category_attributes).reject { |_k, v| v.nil? }
  end

  def self.category_has_fields?(category_id)
    ALL_CATEGORY_IDS_WITH_FIELDS.include? category_id
  end

  def category_has_fields?
    Relationship.category_has_fields?(category_id)
  end

  def get_category
    return nil unless category_has_fields?

    public_send(category_name.downcase)
  end

  def category_attributes
    category = get_category
    return {} if category.nil?

    hash = category.attributes
    hash.delete("id")
    hash.delete("relationship_id")
    hash
  end

  def get_association_data
    { 'document_ids' => documents.map(&:id) }
  end

  #####################

  ## callbacks for soft_delete
  def after_soft_delete
    Link.refresh
    update_entity_links
    references.destroy_all
    position&.destroy! if is_position?
    education&.destroy! if is_education?
    membership&.destroy! if is_membership?
    family&.destroy! if is_family?
    donation&.destroy! if is_donation?
    trans&.destroy! if is_transaction?
    ownership&.destroy! if is_ownership?
    update_entity_timestamps
  end

  def name
    if is_deleted
      "#{category_name_display}: #{unscoped_entity.name}, #{unscoped_related.name}"
    else
      "#{category_name_display}: #{entity.name}, #{related.name}"
    end
  end

  def entity_related_to(e)
    unscoped_entity.id == e['id'] ? unscoped_related : unscoped_entity
  end

  def default_description(order = 1)
    case category_id
    when 5 # donation
      order == 1 ? 'donor' : 'donation recipient'
    when 10 # ownership
      order == 1 ? 'owner' : 'holding/investment'
    when 11 # hierarchy
      order == 1 ? 'child org' : 'parent org'
    when 12 # generic
      'affiliation'
    else
      category_name
    end
  end

  def description_related_to(e)
    order = entity1_id == e.id ? 2 : 1
    desc = order == 1 ? description2 : description1
    desc += (order == 1 ? " (donor)" : " (recipient)") if (desc.present? and category_id == 5)
    return default_description(order) if desc.blank?

    desc
  end

  def details
    RelationshipDetails.new(self).details
  end

  #############
  #   LINKS   #
  #############

  def link
    links.find { |link| link.entity1_id = entity1_id }
  end

  def reversible?
    return true if is_transaction? || is_donation? || is_ownership? || is_hierarchy?
    return true if is_position? && entity.person? && related.person?
    return true if is_membership? && entity.org? && related.org?
    return false
  end

  # Switches entity direction and changes reverses links
  def reverse_direction
    update(entity1_id: entity2_id, entity2_id: entity1_id)
    Link.refresh
  end

  def reverse_direction!
    update!(entity1_id: entity2_id, entity2_id: entity1_id)
    Link.refresh
  end

  ###############################
  # Extension Helpers & Getters #
  ###############################

  def is_board
    position.nil? ? nil : position.is_board
  end

  def is_executive
    position.nil? ? nil : position.is_executive
  end

  def is_employee
    position.nil? ? nil : position.is_employee
  end

  def compensation
    position.nil? ? nil : position.compensation
  end

  # creates category helpers: is_position? is_education? etc.
  %w[POSITION EDUCATION MEMBERSHIP FAMILY DONATION TRANSACTION LOBBYING SOCIAL PROFESSIONAL OWNERSHIP HIERARCHY GENERIC].each do |category|
    define_method "is_#{category.downcase}?" do
      category_id == Relationship.const_get("#{category}_CATEGORY")
    end
  end

  # If the related entity is the U.S. House or Senate
  # AND there is elected_term data on the membership relationship
  def us_legislator?
    is_membership? &&
      NotableEntities.values_at(:house_of_reps, :senate).include?(entity2_id) &&
      membership&.elected_term.present?
  end

  def title
    if description1.blank?
      if is_board
        return "Board Member"
      elsif is_position?
        return "Position"
      elsif is_membership?
        return "Member"
      elsif is_education? and education.degree.present?
        return education.degree.name
      elsif is_family?
      else
        return nil
      end
    else
      description1
    end
  end

  def display_date_range
    RelationshipLabel.new(self).display_date_range
  end

  ## education ##

  def degree
    education.degree.try(:name) if education
  end

  def degree_abbrevation
    education.degree.try(:abbreviation) if education
  end

  def education_field
    education&.field
  end

  def is_dropout
    education&.is_dropout
  end

  ## membership ##

  def membership_dues
    membership.nil? ? nil : membership.dues
  end

  ## Ownership ##

  def percent_stake
    ownership.nil? ? nil : ownership.percent_stake
  end

  def shares_owned
    ownership.nil? ? nil : ownership.shares
  end

  #########################
  # External Relationship #
  #########################

  def update_attributes_from_external_data
    return unless external_relationships.count > 1

    external_datas = external_relationships.includes(:external_data).map(&:external_data).to_a

    self[:start_date] = external_datas.map { |ed| ed.wrapper.date }.min
    self[:end_date] = external_datas.map { |ed| ed.wrapper.date }.max
    self[:amount] = external_datas.map { |ed| ed.wrapper.amount }.sum
    self
  end

  ########################
  # Open Secrets Helpers #
  ########################

  def update_os_donation_info
    self.attributes = { amount: os_donations.sum(:amount), filings: os_donations.count }
    self
  end

  # input: <Date>
  def update_start_date_if_earlier(new_date)
    return if new_date.nil?

    date = LsDate.new(start_date)

    if date.sp_unknown? || new_date < date.coerce_to_date
      update_attribute :start_date, new_date.to_s
    end
  end

  def update_end_date_if_later(new_date)
    return if new_date.nil?

    date = LsDate.new(end_date)

    if date.sp_unknown? || new_date > date.coerce_to_date
      update_attribute :end_date, new_date.to_s
    end
  end

  #############################
  # NYS Contributions helpers #
  #############################

  def update_ny_donation_info
    self.attributes = { amount: ny_disclosures.sum(:amount1), filings: ny_disclosures.count }
    self.attributes = { description1: "NYS Campaign Contribution" } if description1.blank?
    self.attributes = { start_date: ny_transaction_date('asc'), end_date: ny_transaction_date('desc') }
    self
  end

  ##############################
  # External Data/Relationship #
  ##############################

  def external_dataset_name
    external_relationships.first&.dataset
  end

  ########################################
  # Update Entity Timestamp after update #
  ########################################

  # updates timestamp and sets last_user_id for both entities in the relationship
  def update_entity_timestamps
    # The safe navigation operator here is for the
    # the odd-case that an entity has been deleted.
    # TODO: notify admins that a dangling relationship exists?
    entity&.update_timestamp_for(current_user || last_user_id)
    related&.update_timestamp_for(current_user || last_user_id)
  end

  # Removes 'last_user_id' from the json serialization of the object
  # Can include relationship url if option :url is set to true
  def as_json(options = {})
    super(options)
      .reject { |k, _v| k == 'last_user_id' }
      .tap do |h|
        if options[:url]
          h['url'] = Rails.application.routes.url_helpers.relationship_url(self)
        end
        h['name'] = name if options[:name]
      end
  end

  # needed to satisfy Tagable interface
  def description
    "#{entity.name} #{description_sentence[0]} #{related.name} #{description_sentence[1]}"
  end

  # Array of api data for the entities in the relationship
  def api_included
    @api_included ||= [entity.api_data(exclude: :extensions), related.api_data(exclude: :extensions)]
  end

  def restore!
    raise Exceptions::CannotRestoreError unless is_deleted
    return nil if entity.nil? || related.nil? || entity.is_deleted || related.is_deleted
    association_data = retrieve_deleted_association_data
    run_callbacks :create
    update(is_deleted: false)
    if association_data.present? && association_data['document_ids'].present?
      association_data['document_ids'].each do |doc_id|
        references.find_or_create_by(document_id: doc_id)
      end
    end
  end

  # -> [ entity1_id, entity2_id, category_id ]
  def triplet
    [entity1_id, entity2_id, category_id]
  end

  def url
    Rails.application.routes.url_helpers.relationship_url(self)
  end

  concerning :DateSorting do
    def temporal_status
      case is_current
      when true
        :current
      when false
        :past
      when nil
        :unknown
      end
    end

    def temporal_status_rank
      TEMPORAL_STATUS_RANK[temporal_status]
    end

    def end_date_rank
      end_date.blank? ? 1 : 0
    end

    def date_rank
      [
        temporal_status_rank,
        start_date.to_s,
        end_date_rank,
        end_date.to_s,
        updated_at
      ]
    end
  end

  private

  # Updates link count for entities
  # called after a relationship is created or removed
  def update_entity_links
    entity&.update_link_count
    related&.update_link_count
  end

  def ny_transaction_date(sort)
    raise Exception unless %w[asc desc].include?(sort)

    ny_disclosures
      .select('schedule_transaction_date')
      .order("schedule_transaction_date #{sort}")
      .limit(1)
      &.first
      &.schedule_transaction_date
  end

  def update_is_current_according_to_end_date
    return if end_date.blank?

    ls_end_date = LsDate.new(end_date)

    if ls_end_date.sp_day? && ls_end_date < LsDate.today
      self.is_current = false
    end
  end

  def set_currency_default
    if currency.present?
      self.currency = currency.to_s.downcase
    elsif amount.present?
      self.currency = 'usd'
    end
  end
end

# rubocop:enable Naming/PredicateName, Style/StringLiterals
