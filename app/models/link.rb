# coding: utf-8
class Link < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :links
  belongs_to :entity, foreign_key: "entity1_id", inverse_of: :links
  belongs_to :related, class_name: "Entity", foreign_key: "entity2_id", inverse_of: :reverse_links
  has_many :references, through: :relationship
  has_many :chained_links, class_name: "Link", foreign_key: "entity1_id", primary_key: "entity2_id"

  def self.interlock_hash_from_entities(entity_ids)
    interlock_hash(where(entity1_id: entity_ids))
  end

  def self.interlock_hash(links)
    links.reduce({}) do |hash, link|
      hash[link.entity2_id] = hash.fetch(link.entity2_id, []).push(link.entity1_id).uniq
      hash
    end
  end

  def position_type 
    return 'None' unless category_id == 1

    org_types = related.extension_names

    return 'business' if (org_types & ['Business', 'BusinessPerson']).any?
    return 'government' if org_types.include? 'GovernmentBody'
    return 'office' if (org_types & ['ElectedRepresentative', 'PublicOfficial']).any?
    return 'other'
  end

  def is_pfc_link?
    return false if related == nil
    # definition_id = 11
    related.extension_names.include? 'PoliticalFundraising'
  end

  def description
    return relationship.title if relationship.is_position? || relationship.is_member?
    return humanize_contributions if relationship.is_donation?
    return education_description if relationship.is_education?
    text = is_reverse ? relationship.description1 : relationship.description2
    return text unless text.blank?
    return default_description
  end

  private

  def humanize_contributions
    str = ""

    if relationship.filings.nil? || relationship.filings.zero?

      if relationship.description1 == 'NYS Campaign Contribution'
        str << "NYS Campaign Contribution"
      elsif relationship.description1 == "Campaign Contribution"
        str << "Donation"
      elsif relationship.description1.present?
        str << relationship.description1
      else
        str << default_description
      end

    else
      str << ActionController::Base.helpers.pluralize(relationship.filings, 'contribution')
    end

    unless relationship.amount.nil?
      str << " · "
      str << ActiveSupport::NumberHelper.number_to_currency(relationship.amount, precision: 0)
    end
    str
  end

  def education_description
    degree = relationship.degree_abbrevation || relationship.degree || default_description
    field = relationship.education_field
    return "#{degree}, #{field}" if field
    degree
  end

  def default_description
    case category_id
    when 1
      return 'Position'
    when 2
      return relationship.description1 if relationship.description1.present?
      return 'Student' if is_reverse
      return 'School' unless is_reverse
    when 3
      return 'Member'
    when 4
      return 'Relative'
    when 5
      return 'Donation/Grant'
    when 6
      return 'Service/Transaction'
    when 7
      return 'Lobbying'
    when 8
      return 'Social'
    when 9
      return 'Professional'
    when 10
      return 'Owner'
    when 11
      return 'Child Org' if is_reverse
      return 'Parent Org' unless is_reverse
    when 12
      return 'Affiliation'
    else
      return ''
    end
  end
  
end
