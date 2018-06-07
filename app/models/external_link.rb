# frozen_string_literal: true

class ExternalLink < ApplicationRecord
  belongs_to :entity

  # 1 -> sec
  # 2 -> wikipedia
  enum link_type: %i[reserved sec wikipedia]

  LINK_PLACEHOLDER = '{}'
  EDITABLE_TYPES = %i[wikipedia sec].freeze

  validates :link_type, presence: true
  validates :entity_id, presence: true
  validates :link_id, presence: true

  def url
    url_template.gsub(LINK_PLACEHOLDER, link_id)
  end

  def title
    case link_type
    when 'sec'
      'Sec - Edgar'
    when 'wikipedia'
      'Wikipedia'
    when 'reserved'
      raise TypeError, 'Do not create ExternalLinks of type "reserved"'
    end
  end

  # returns only editable links that can be edited
  def self.find_or_initalize_links_for(entity)
    EDITABLE_TYPES.map do |link_type|
      find_or_initialize_by(link_type: link_type,
                            entity_id: Entity.entity_id_for(entity))
    end
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
