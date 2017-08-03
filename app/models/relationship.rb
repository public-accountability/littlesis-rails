# coding: utf-8
class Relationship < ActiveRecord::Base
  include SingularTable
  include SoftDelete
  include Referenceable
  include RelationshipDisplay
  include SimilarRelationships
  include Tagable

  has_paper_trail :ignore => [:last_user_id],
                  :meta => { :entity1_id => :entity1_id, :entity2_id => :entity2_id }

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

  has_many :links, inverse_of: :relationship, dependent: :destroy
  belongs_to :entity, foreign_key: "entity1_id"
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id"
  has_many :references, -> { where(object_model: 'Relationship') }, foreign_key: 'object_id'

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

  # fec_filings are no longer used
  has_many :fec_filings, inverse_of: :relationship, dependent: :destroy
  belongs_to :category, class_name: "RelationshipCategory", inverse_of: :relationships
  belongs_to :last_user, class_name: "SfGuardUser", foreign_key: "last_user_id"

  # Open Secrets
  has_many :os_matches, inverse_of: :relationship
  has_many :os_donations, through: :os_matches

  # NY Contributions
  has_many :ny_matches, inverse_of: :relationship
  has_many :ny_disclosures, through: :ny_matches

  validates_presence_of :entity1_id, :entity2_id, :category_id
  validates :start_date, length: { maximum: 10 }, date: true
  validates :end_date, length: { maximum: 10 }, date: true
  validates_with RelationshipValidator

  after_create :create_category, :create_links, :update_entity_links
  # This callback is basically a modified version of :touch => true
  # It updates the entity timestamps and also changes the last_user_id of
  # associated entities for the relationship
  after_save :update_entity_timestamps
  
  ##############
  # CATEGORIES #
  ##############

  def create_category
    self.class.all_categories[category_id].constantize.create(relationship: self) if self.class.all_category_ids_with_fields.include?(category_id)
  end 

  def create_links
    Link.create(entity1_id: entity1_id, entity2_id: entity2_id, category_id: category_id, is_reverse: false, relationship: self)
    Link.create(entity1_id: entity2_id, entity2_id: entity1_id, category_id: category_id, is_reverse: true, relationship: self)
  end

  def self.all_categories
    [
      "",
      "Position",
      "Education",
      "Membership",
      "Family",
      "Donation",
      "Transaction",
      "Lobbying",
      "Social",
      "Professional",
      "Ownership",
      "Hierarchy",
      "Generic"
    ]
  end

  def self.category_hash
    Hash[[*all_categories.map.with_index]].invert.select { |k, v| v.present? }
  end

  def self.all_categories_with_fields
    [
      "Position",
      "Education",
      "Membership",
      "Family",
      "Donation",
      "Transaction",
      "Ownership"
    ]
  end

  def self.all_category_ids_with_fields
    [1, 2, 3, 4, 5, 6, 10]
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
    self.class.all_categories[category_id]
  end
  
  def all_attributes
    attributes.merge!(category_attributes).reject { |k,v| v.nil? }
  end

  def get_category
    return nil unless self.class.all_categories_with_fields.include? category_name

    Kernel.const_get(category_name)
      .where(relationship_id: id)
      .first
  end

  def category_attributes
    category = get_category
    return {} if category.nil?

    hash = category.attributes
    hash.delete("id")
    hash.delete("relationship_id")
    hash
  end

  #####################

  ## callbacks for soft_delete
  def after_soft_delete
    links.destroy_all
    update_entity_links
    position&.destroy! if is_position?
    education&.destroy! if is_education?
    membership&.destroy! if is_member?
    family&.destroy! if is_family?
    donation&.destroy! if is_donation?
    trans&.destroy! if is_transaction?
    ownership&.destroy! if is_ownership?
  end
 
  def legacy_url(action=nil)
    self.class.legacy_url(id, action)
  end

  def self.legacy_url(id, action=nil)
    action = action.nil? ? "view" : action
    "/relationship/#{action}/id/#{id.to_s}"
  end

  def full_legacy_url
    "//littlesis.org" + legacy_url
  end

  def name
    "#{category_name}: #{entity.name}, #{related.name}"
  end

  def entity_related_to(e)
    entity.id == e.id ? related : entity
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

  def source_links
    Reference.where(object_id: self.id, object_model: "Relationship")
  end


  #############
  #   LINKS   #
  #############

  def link
    links.find { |link| link.entity1_id = entity1_id }
  end

  def is_reversible?
    is_transaction? || is_donation? || is_ownership? || is_hierarchy? || (is_position? && entity.person? && related.person?)
  end

  # COMMENT: does this func work? is it used? (ziggy 2017-02-08) 
  def reverse_link
    links.find { |link| linl.entity2_id = entity1_id }
  end

  def reverse_links
    links.each do |link|
      if link.is_reverse == true
        link.update(is_reverse: false)
      else
        link.update(is_reverse: true)
      end
    end
  end

  # Switches entity direction and changes reverses links
  def reverse_direction
    update(entity1_id: entity2_id, entity2_id: entity1_id)
    reverse_links
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

  def is_position?
    category_id == POSITION_CATEGORY
  end

  def is_member?
    category_id == MEMBERSHIP_CATEGORY
  end

  def is_education?
    category_id == EDUCATION_CATEGORY
  end

  def is_family?
    category_id == FAMILY_CATEGORY
  end

  def is_donation?
    category_id == DONATION_CATEGORY
  end

  def is_transaction?
    category_id == TRANSACTION_CATEGORY
  end

  def is_ownership?
    category_id == OWNERSHIP_CATEGORY
  end

  def is_hierarchy?
    category_id == HIERARCHY_CATEGORY
  end

  def title
    if description1.blank?
      if is_board
        return "Board Member"
      elsif is_position?
        return "Position"
      elsif is_member?
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
    if start_date.nil? && end_date.nil?
      return '(past)' if is_current == false
      return ''
    end
    if start_date == end_date || (is_donation? && end_date.nil?)
      return "(#{LsDate.new(start_date).display})"
    end
    "(#{LsDate.new(start_date).display}→#{LsDate.new(end_date).display})"
  end
  
  ## education ##
  
  def degree
    education.nil? ? nil : education.degree.try(:name)
  end
    
  def education_field
    education.nil? ? nil : education.field
  end

  def is_dropout
    education.nil? ? nil : education.is_dropout
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

  ## position ##

  def position_or_membership_type 
    return 'None' unless (is_position? || is_member?)

    org_types = related.extension_names

    return 'Business' if (org_types & ['Business', 'BusinessPerson']).any?
    return 'Government' if org_types.include? 'GovernmentBody'
    return 'In The Office Of' if (org_types & ['ElectedRepresentative', 'PublicOfficial']).any?
    return 'Other Positions & Memberships'
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
    return nil if new_date.nil?
    if date_string_to_date(:start_date).nil?
      update_attribute(:start_date, new_date.to_s)
    elsif new_date < date_string_to_date(:start_date)
      update_attribute(:start_date, new_date.to_s)
    else
      # no change
    end
  end

  def update_end_date_if_later(new_date)
    return nil if new_date.nil?
    if date_string_to_date(:end_date).nil?
      update_attribute(:end_date, new_date.to_s)
    elsif new_date > date_string_to_date(:end_date)
      update_attribute(:end_date, new_date.to_s)
    else
      # no change
    end
  end

  def date_string_to_date(field)
    return nil if public_send(field).nil?
    year, month, day = public_send(field).split("-").map { |x| x.to_i }
    if year.blank? or year == 0
      nil
    else
      if month.blank? or month == 0
        Date.new(year)
      else
        if day.blank? or day == 0
          Date.new(year, month)
        else
          Date.new(year, month, day)
        end
      end
    end    
  end  

  #############################
  # NYS Contributions helpers #
  #############################

  def update_ny_donation_info
    self.attributes = { amount: ny_disclosures.sum(:amount1), filings: ny_disclosures.count }
    self.attributes = { description1: "NYS Campaign Contribution" } if description1.blank?
    self
  end
  

  ########################################
  # Update Entity Timestamp after update #
  ########################################

  # updates timestamp and sets last_user_id of
  # both entities in the relationship
  def update_entity_timestamps(sf_user_id = nil)
    lui = last_user_id_for_entity_update(sf_user_id)

    # In case a entity has been deleted...
    # TODO: create a warning to let admins know
    # that dangling relationship exists?
    unless entity.nil?
      if entity.last_user_id == lui
        entity.touch
      else
        entity.update(last_user_id: lui)
      end
    end

    unless related.nil?
      if related.last_user_id == lui
        related.touch
      else
        related.update(last_user_id: lui)
      end
    end

  end

  # Removes 'last_user_id' from the json serialization of the object
  # Can include relationship url if option :url is set to true
  def as_json(options = {})
    super(options)
      .reject { |k, v| k == 'last_user_id' }
      .tap do |h|
        if options[:url]
          h['url'] = Rails.application.routes.url_helpers.relationship_url(self)
        end
        h['name'] = name if options[:name]
      end
  end

  private

  def last_user_id_for_entity_update(sf_user_id = nil)
    # if called with a 'sf_user_id' use that id
    return sf_user_id unless sf_user_id.nil?
    # if, for some reason, the relationship's last_user_id is nil, use that
    return APP_CONFIG.fetch('system_user_id') if last_user_id.nil?
    # otherwise, use the relationship's last_user_id
    last_user_id
  end

  # Updates link count for entities
  # called after a relationship is created or removed
  def update_entity_links
    entity&.update_link_count
    related&.update_link_count
  end
end
