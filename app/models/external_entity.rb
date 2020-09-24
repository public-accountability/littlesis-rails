# frozen_string_literal: true

# External Entity links a LittleSis Entity to a row in External Data
#
#   ExternalEntity#matches              ResultSet of potential matches
#   ExternalEntity#search_for_matches   Search entities for possible match
#   ExternalEntity#automatch            Automatically matches, if possible
#   ExternalEntity#match_with(<Entity>) Performs match
#   ExternalEntity#unmatch!             Reverts Match
#
#   ^^ These methods are defined in models/external_entity/datasets/<dataset_name>.rb
#
class ExternalEntity < ApplicationRecord
  include Datasets::Interface

  NYCC_LIST_ID = 2780

  enum dataset: ExternalData::DATASETS
  validates :dataset, presence: true

  enum priority: { default: 0 }

  serialize :match_data

  belongs_to :external_data, optional: false
  belongs_to :entity, optional: true

  before_create :set_primary_ext

  # Some methods (i.e. matches, datatables_search, etc.) differ
  # for each dataset and are defined in modules.
  # For example the module ExternalEntity::Datasets::IapdAdvisors
  # is extended if record's dataset is iapd_advisors
  after_initialize do
    extend "ExternalEntity::Datasets::#{dataset.classify}".constantize
  end

  # is it already connected to an entity
  def matched?
    !entity_id.nil?
  end

  # Performs a match between the external data and an entity.
  # If already matched, an error is raised.
  # There are dataset-specific side effects of matching. see #match_action
  def match_with(entity_or_id)
    raise AlreadyMatchedError, "ExternalEntity (#{id}) is already matched" if matched?

    ApplicationRecord.transaction do
      update!(entity_id: Entity.entity_id_for(entity_or_id))
      add_reference
      match_action
    end
    self
  end

  # Creates a new entity and then calls match_with
  # entity_params: hash
  def match_with_new_entity(entity_params)
    ApplicationRecord.transaction do
      match_with Entity.create!(entity_params)
    end
    self
  end

  # This removed the entity_id and calls unmatch_match.
  # For many datasets this will not *fully* revert the effects of #match_action
  def unmatch!
    raise Exceptions::LittleSisError, "Not yet matched" unless matched?

    ApplicationRecord.transaction do
      unmatch_action
      update!(entity_id: nil)
    end
  end

  def presenter
    ExternalEntityPresenter.new(self)
  end

  def self.unmatched
    where(entity_id: nil)
  end

  def self.matched
    where.not(entity_id: nil)
  end

  def self.random_unmatched(dataset = nil)
    ExternalEntity
      .public_send(dataset || :itself)
      .unmatched
      .order('RAND()')
      .limit(1)
      .first
  end

  class AlreadyMatchedError < Exceptions::MatchingError; end
end
