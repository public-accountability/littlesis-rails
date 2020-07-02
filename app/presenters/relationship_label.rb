# frozen_string_literal: true

# Provides a short label for a Relationship.
# Used by Link and Oligrapher.
class RelationshipLabel < SimpleDelegator
  include ActiveSupport::NumberHelper

  attr_reader :is_reverse

  def initialize(relationship, is_reverse = false)
    super(relationship)
    @is_reverse = is_reverse
  end

  def display_date_range
    if start_date.nil? && end_date.nil?
      return '(past)' if temporal_status == :past

      return ''
    end

    if start_date == end_date || (is_donation? && end_date.nil?)
      return "(#{LsDate.new(start_date).display})"
    end

    "(#{LsDate.new(start_date).display}→#{LsDate.new(end_date).display})"
  rescue LsDate::InvalidLsDateError
    return ''
  end

  # This returns the label for the provided entity of a relationship.
  # The semantics of this can be somewhat confusing. You can think of
  # it as the label for the page of the provided entity.
  #
  # This is an alterative to setting is_reverse
  #
  # For instance. if there's a relationship between Alice and Bob,
  # where Alice is Entity #1 and Bob is Enity #2 and description1 = "renter"
  # and description2  = "landlord". Our convention is to say that Alice is
  # the renter of Bob and Bob is the landlord of Alice.
  # Howver label_for_page_of(Alice) would return "Landlord" and
  # label_for_page_of(Bob) would return "renter"
  def label_for_page_of(entity)
    prev_is_reverse = @is_reverse
    entity_id = Entity.entity_id_for(entity)
    @is_reverse = (entity_id == entity2_id)
    return label
  ensure
    @is_reverse = prev_is_reverse
  end

  def label
    return title if is_position? || is_membership?
    return humanize_contributions if is_donation?
    return education_label if is_education?
    return transaction_label if is_transaction?
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

  def transaction_label
    text = (is_reverse ? description1 : description2).presence || default_description
    return text if amount.nil? || amount.zero?

    "#{text} · #{amount_display}"
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

    str << " · #{amount_display}" unless amount.nil?
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

  def amount_display
    number_to_currency(amount, unit: currency.upcase, precision: 0, format: '%n %u')
  end
end
