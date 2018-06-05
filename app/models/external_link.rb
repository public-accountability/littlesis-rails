# frozen_string_literal: true

class ExternalLink < ApplicationRecord
  belongs_to :entity

  LINK_PLACEHOLDER = '{}'

  # 1 -> sec
  # 2 -> wikipedia
  enum link_type: %i[reserved sec wikipedia]

  validates :link_type, presence: true
  validates :entity_id, presence: true
  validates :link_id, presence: true

  def url
    url_template.gsub(LINK_PLACEHOLDER, link_id)
  end

  private

  def url_template
    case link_type
    when 'sec'
      'https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK={}&output=xml'
    when 'wikipedia'
      'TODO'
    when 'reserved'
      raise TypeError, 'Do not create ExernalLinks of type "reserved"'
    end
  end
end
