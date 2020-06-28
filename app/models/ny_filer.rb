# frozen_string_literal: true

# A NyFiler is a committee or PAC registered with the NYS board of elections
# Filter types
#  1      Individual campaign committee
#  2      PAC
#  3-7    Constituted/party Committees
#  3H-7H  Constituted/party campaign finance registration form
#  8      Independent Expenditure Committee (unauthorized)
#  9      Authorized Multi-Candidate Committees
#  9B     Ballot Issue Committee
# Source: https://www.elections.ny.gov/NYSBOE/download/finance/hndbk2019.pdf
# Forms: https://www.elections.ny.gov/CampaignFinanceForms.html
#
class NyFiler < ApplicationRecord
  has_one :ny_filer_entity, dependent: :destroy
  has_one :unmatched_ny_filer, dependent: :destroy
  has_many :entities, :through => :ny_filer_entity
  has_many :ny_disclosures,
           primary_key: 'filer_id',
           foreign_key: 'filer_id',
           inverse_of: :ny_filer,
           dependent: :restrict_with_exception

  validates :filer_id, presence: true, uniqueness: { case_sensitive: false }

  ENTITY_MATCHES_COUNT = 10

  def is_matched?
    ny_filer_entity.present?
  end

  alias matched? is_matched?

  def raise_if_matched!
    raise AlreadyMatchedError if matched?
  end

  def office_description
    NYSCampaignFinance::OFFICES[office]
  end

  # --> [EntityMatcher::EvaluationResult::Base]
  def entity_matches
    return @_entity_match if defined?(@_entity_match)

    @_entity_match = EntityMatcher::NyFiler.matches(self).take(ENTITY_MATCHES_COUNT)
  end

  def match_to_person?
    committee_type == '1'
  end

  #---------------#
  # Class methods #
  #---------------#

  def self.datatable
    joins(:unmatched_ny_filer)
      .order('unmatched_ny_filers.disclosure_count desc')
  end

  def self.unmatched
    left_outer_joins(:ny_filer_entity)
      .where('ny_filer_entities.id is NULL')
  end

  def self.search_filers(name)
    search_by_name_and_committee_type(name, ['1', ''])
  end

  def self.search_pacs(name)
    search_by_name_and_committee_type(name, ['2', '9', '8'])
  end

  def self.cuomo
    find_by filer_id: 'A31966'
  end

  # str, [ str ] => <ThinkingSphinx::Search>
  private_class_method def self.search_by_name_and_committee_type(name, committee_types)
    NyFiler.search(name,
                    :sql => { :include => :ny_filer_entity },
                    :with => { :committee_type => committee_types })
  end

  class AlreadyMatchedError < StandardError; end
end
