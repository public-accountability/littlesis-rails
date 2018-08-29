# frozen_string_literal: true

# Provides a short label for a Relationship.
# Used by Link and Oligrapher.
class RelationshipLabel < SimpleDelegator
  attr_reader :is_reverse

  def initialize(relationship, is_reverse = false)
    super(relationship)
    @is_reverse = is_reverse
  end

  def label
    return title if is_position? || is_member?
    return humanize_contributions if is_donation?
    return education_label if is_education?
    text = is_reverse ? description1 : description2
    return text if text.present?
    default_description
  end

  private

  def education_label
    education_description = degree_abbrevation || degree || default_description
    return "#{education_description}, #{education_field}" if education_field
    education_description
  end

  def humanize_contributions
    str = +''

    if filings.nil? || filings.zero?

      if description1 == 'NYS Campaign Contribution'
        str << 'NYS Campaign Contribution'
      elsif description1 == 'Campaign Contribution'
        str << 'Donation'
      elsif description1.present?
        str << description1
      else
        str << default_description
      end

    else
      str << ActionController::Base.helpers.pluralize(filings, 'contribution')
    end

    unless amount.nil?
      str << " · "
      str << ActiveSupport::NumberHelper.number_to_currency(amount, precision: 0)
    end
    str
  end

  def default_description
    case category_id
    when 1
      return 'Position'
    when 2
      return description1 if description1.present?
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
