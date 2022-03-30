# frozen_string_literal: true

# ExternalLink is a unique identifier from another organization
# Some ExternalLinks, such as twitter handles and wikipedia pages, can be
# edited by users. Others (editable = false) can only be updated by system bots.
#
# `link_id` is the identifier and should be unique (for each type)
#
class ExternalLink < ApplicationRecord
  LINK_TYPES = {
    reserved: {
      enum_val: 0,
      title: nil,
      url: nil,
      editable: nil,
      internal: nil,
      multiple: nil
    },
    sec: {
      enum_val: 1,
      title: 'Sec - Edgar',
      url: 'https://www.sec.gov/cgi-bin/browse-edgar?action=getcompany&CIK={}&output=xml',
      editable: false,
      internal: false,
      multiple: false
    },
    wikipedia: {
      enum_val: 2,
      title: 'Wikipedia: {}',
      url: 'https://en.wikipedia.org/wiki/{}',
      editable: true,
      internal: false,
      multiple: false
    },
    twitter: {
      enum_val: 3,
      title: 'Twitter @{}',
      url: 'https://twitter.com/{}',
      editable: true,
      internal: false,
      multiple: false
    },
    crd: {
      enum_val: 4,
      title: 'Investment Adviser Public Disclosure: {}',
      grouped_title: 'Investment Adviser Public Disclosures',
      url: ->(elink) do
        if elink.entity.primary_ext == 'Org'
          'https://adviserinfo.sec.gov/Firm/{}'
        else
          'https://adviserinfo.sec.gov/Individual/{}'
        end
      end,
      editable: false,
      internal: false,
      multiple: true
    },
    nys_filer: {
      enum_val: 5,
      title: 'NYS Board of Election Filer: {}',
      grouped_title: 'NYS Board of Election Filings',
      url: 'https://cfapp.elections.ny.gov/ords/plsql_browser/getfiler2_loaddates?filerid_IN={}',
      editable: false,
      internal: true,           # These were discontinued in 2021. see nys_committee
      multiple: true
    },
    sapi: {
      enum_val: 6,
      title: 'SAPI Identifier: {}',
      url: nil,
      editable: false,
      internal: true,
      multiple: false
    },
    fec_candidate: {
      enum_val: 7,
      title: 'FEC Candidate: {}',
      grouped_title: 'FEC Candidate',
      url: 'https://www.fec.gov/data/candidate/{}/',
      editable: false,
      internal: false,
      multiple: true
    },
    fec_committee: {
      enum_val: 8,
      title: 'FEC Committee: {}',
      url: 'https://www.fec.gov/data/committee/{}/',
      editable: false,
      internal: false,
      multiple: false
    },
    nys_committee: {
      enum_val: 9,
      title: 'NYS Campaign Finance Committee: {}',
      url: nil,
      editable: false,
      internal: false,
      multiple: true
    }
  }.with_indifferent_access.freeze

  enum link_type: LINK_TYPES.transform_values { |x| x[:enum_val] }.freeze
  belongs_to :entity

  has_paper_trail on:  %i[create destroy update],
                  if: ->(el) { el.editable? },
                  meta: { entity1_id: :entity_id },
                  versions: { class_name: 'ApplicationVersion' }


  PLACEHOLDER = '{}'
  WIKIPEDIA_REGEX = Regexp.new 'https?:\/\/en.wikipedia.org\/wiki\/?(.+)', Regexp::IGNORECASE
  TWITTER_REGEX = Regexp.new 'https?:\/\/twitter.com\/?(.+)', Regexp::IGNORECASE

  validates :link_type, presence: true
  validates :entity_id, presence: true
  validates :link_id, presence: true
  validates_with ExternalLinkValidator, on: :create

  before_validation :parse_id_input

  after_save ->{ entity.touch }, unless: :internal?

  def editable?
    LINK_TYPES.dig(link_type, :editable)
  end

  def internal?
    LINK_TYPES.dig(link_type, :internal)
  end

  def url
    template = LINK_TYPES.dig(link_type, :url)
    template = template.call(self) if template.is_a?(Proc)
    template&.gsub(PLACEHOLDER, link_id)
  end

  def title
    LINK_TYPES
      .dig(link_type, :title)
      .gsub(PLACEHOLDER, link_id)
  end

  # returns only the links that can be edited
  def self.find_or_initialize_links_for(entity)
    editable_link_types = LINK_TYPES.select { |_k, v| v[:editable] }.keys

    editable_link_types.map do |link_type|
      find_or_initialize_by(link_type: link_type,
                            entity_id: Entity.entity_id_for(entity))
    end
  end

  # input: Integer | String | Symbol
  def self.info(x)
    LINK_TYPES.find do |k, v|
      v[:enum_val] == x || k == x.to_s
    end
  end

  # Finds the Sec ExternalLink for the given cik
  # `.to_i.to_s` removes leading 0's which is how cik numbers are stored in our database
  def self.find_by_cik(cik)
    sec.find_by(link_id: cik.to_i.to_s)
  end

  def self.crd_number?(crd)
    return false if crd.blank? || crd.include?('-')

    /\A\d+\z/.match?(crd)
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
