# frozen_string_literal: true

class ExternalLink < ApplicationRecord
  belongs_to :entity

  has_paper_trail on:  %i[create destroy update],
                  meta: { entity1_id: :entity_id },
                  if: ->(el) { el. editable? }

  # 1 -> sec
  # 2 -> wikipedia
  enum link_type: %i[reserved sec wikipedia]
  LINK_TYPE_IDS = link_types.to_a.map(&:reverse).to_h.freeze

  LINK_PLACEHOLDER = '{}'
  EDITABLE_TYPES = %w[wikipedia].freeze

  WIKIPEDIA_REGEX = Regexp.new 'https?:\/\/en.wikipedia.org\/wiki\/?(.+)', Regexp::IGNORECASE

  validates :link_type, presence: true
  validates :entity_id, presence: true
  validates :link_id, presence: true

  before_validation :parse_id_input

  def editable?
    EDITABLE_TYPES.include?(link_type)
  end

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

  # handles input of wikipedia links
  def parse_id_input
    if wikipedia? && WIKIPEDIA_REGEX.match?(link_id)
      self.link_id = WIKIPEDIA_REGEX.match(link_id)[1]
    end
  end

  def url_template
    case link_type
    when 'sec'
      'https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK={}&output=xml'
    when 'wikipedia'
      'https://en.wikipedia.org/wiki/{}'
    when 'reserved'
      raise TypeError, 'Do not create ExternalLinks of type "reserved"'
    end
  end
end
