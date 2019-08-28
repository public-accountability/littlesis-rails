# frozen_string_literal: true

class ExternalLink < ApplicationRecord
  LINK_TYPES = {
    reserved: {
      enum_val: 0,
      title: nil,
      url: nil,
      editable: nil,
      multiple: nil
    },
    sec: {
      enum_val: 1,
      title: 'Sec - Edgar',
      url: 'https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK={}&output=xml',
      editable: false,
      multiple: false
    },
    wikipedia: {
      enum_val: 2,
      title: 'Wikipedia: {}',
      url: 'https://en.wikipedia.org/wiki/{}',
      editable: true,
      multiple: false
    },
    twitter: {
      enum_val: 3,
      title: 'Twitter @{}',
      url: 'https://twitter.com/{}',
      editable: true,
      multiple: false
    },
    crd: {
      enum_val: 4,
      title: nil,
      url: nil,
      editable: false,
      multiple: true
    }
  }.with_indifferent_access.freeze

  enum link_type: LINK_TYPES.transform_values { |x| x[:enum_val] }.freeze

  belongs_to :entity

  has_paper_trail on:  %i[create destroy update],
                  meta: { entity1_id: :entity_id },
                  if: ->(el) { el. editable? }

  PLACEHOLDER = '{}'
  WIKIPEDIA_REGEX = Regexp.new 'https?:\/\/en.wikipedia.org\/wiki\/?(.+)', Regexp::IGNORECASE
  TWITTER_REGEX = Regexp.new 'https?:\/\/twitter.com\/?(.+)', Regexp::IGNORECASE

  validates :link_type, presence: true
  validates :entity_id, presence: true
  validates :link_id, presence: true
  validates_with ExternalLinkValidator, on: :create

  before_validation :parse_id_input

  def editable?
    LINK_TYPES.dig(link_type, :editable)
  end

  def url
    LINK_TYPES
      .dig(link_type, :url)
      .gsub(PLACEHOLDER, link_id)
  end

  def title
    LINK_TYPES
      .dig(link_type, :title)
      .gsub(PLACEHOLDER, link_id)
  end

  # returns only editable links that can be edited
  def self.find_or_initialize_links_for(entity)
    editable_link_types = LINK_TYPES.select { |_k, v| v[:editable] }.keys

    editable_link_types.map do |link_type|
      find_or_initialize_by(link_type: link_type,
                            entity_id: Entity.entity_id_for(entity))
    end
  end

  # input: Integer | String | sym
  def self.info(x)
    LINK_TYPES.find do |k, v|
      v[:enum_val] == x || k == x.to_s
    end
  end

  private

  # handles input of wikipedia & twitter links
  def parse_id_input
    if wikipedia? && WIKIPEDIA_REGEX.match?(link_id)
      self.link_id = WIKIPEDIA_REGEX.match(link_id)[1]
    elsif twitter?
      if TWITTER_REGEX.match?(link_id)
        self.link_id = TWITTER_REGEX.match(link_id)[1]
      elsif link_id.strip[0] == '@'
        self.link_id = link_id.strip[1..-1]
      end
    end
  end
end
