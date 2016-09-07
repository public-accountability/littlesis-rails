class Relationship < ActiveRecord::Base
  include SingularTable
  include SoftDelete
  include Referenceable
  include RelationshipDisplay
  
  POSITION_CATEGORY = 1
  EDUCATION_CATEGORY = 2
  MEMBERSHIP_CATEGORY = 3
  FAMILY_CATEGORY = 4
  DONATION_CATEGORY = 5
  TRANSATION_CATEGORY = 6
  LOBBYING_CATEGORY = 7
  SOCIAL_CATEGORY = 8
  PROFESSIONAL_CATEGORY = 9
  OWNERSHIP_CATEGORY = 10
  HIERARCHY_CATEGORY = 11
  GENERIC_CATEGORY = 12

  has_many :links, inverse_of: :relationship, dependent: :destroy
  belongs_to :entity, foreign_key: "entity1_id"
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id"
  
  # has_many :note_relationships, inverse_of: :relationship
  # has_many :notes, through: :note_relationships, inverse_of: :relationships
  
  has_one :position, inverse_of: :relationship, dependent: :destroy
  has_one :education, inverse_of: :relationship, dependent: :destroy
  has_one :membership, inverse_of: :relationship, dependent: :destroy
  has_one :family, inverse_of: :relationship, dependent: :destroy
  has_one :donation, inverse_of: :relationship, dependent: :destroy
  has_one :trans, class_name: "Transaction", inverse_of: :relationship, dependent: :destroy
  has_one :ownership, inverse_of: :relationship, dependent: :destroy
  has_many :fec_filings, inverse_of: :relationship, dependent: :destroy
  belongs_to :category, class_name: "RelationshipCategory", inverse_of: :relationships

  belongs_to :last_user, class_name: "SfGuardUser", foreign_key: "last_user_id"

  # Open Secrets 
  has_many :os_matches, inverse_of: :relationship
  has_many :os_donations, through: :os_matches

  validates_presence_of :entity1_id, :entity2_id, :category_id

  after_create :create_category, :create_links

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

  def link
    links.find { |link| link.entity1_id = entity1_id }
  end
  
  def reverse_link
    links.find { |link| linl.entity2_id = entity1_id }
  end

  def category_name
    self.class.all_categories[category_id]
  end
  
  def all_attributes
    hash = attributes.merge!(category_attributes).reject { |k,v| v.nil? }
    hash.delete("notes")
    hash
  end

  def category_attributes
    return {} unless self.class.all_categories_with_fields.include? category_name

    category = Kernel.const_get(category_name)
                     .where(relationship_id: id)
                     .first
    return {} if category.nil?

    hash = category.attributes
    hash.delete("id")
    hash.delete("relationship_id")
    hash
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

  def is_member?
    category_id == MEMBERSHIP_CATEGORY
  end

  def is_education?
    category_id == EDUCATION_CATEGORY
  end

  def is_family?
    category_id == FAMILY_CATEGORY
  end
  
  def title
    if description1.blank?
      if is_board
        return "Board Member"
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
  
  def details 
    RelationshipDetails.new(self).details
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
    if date_string_to_date(:start_date).nil?
      update_attribute(:start_date, new_date.to_s)
    elsif new_date < date_string_to_date(:start_date)
      update_attribute(:start_date, new_date.to_s)
    else
      # no change
    end
  end

  def update_end_date_if_later(new_date)
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

end
