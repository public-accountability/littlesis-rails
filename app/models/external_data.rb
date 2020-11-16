# frozen_string_literal: true

# These are pieces of data -- typically a row in a spreadsheet -- from
# an external data source (example: CSVs from the Securities and Exchange Commission)
#
# They are organized into datasets and the attribute "dataset_id" must be a unique.
# This is often a corporate or personal identifier (example:  Board of Elections Filer ID),
# but it can be any string.
#
# The attribute "data" is the imported data from the external dataset. In MYSQL,
# it is stored as json and serialized as an Hash or Array in rails.
#
class ExternalData < ApplicationRecord
  DATASETS = {
    reserved: 0,
    iapd_advisors: 1,
    iapd_schedule_a: 2, # relationship
    nycc: 3,
    nys_disclosure: 4, # relationship
    nys_filer: 5,
    fec_candidate: 6,
    fec_committee: 7,
    fec_contribution: 8, # relationship
    fec_donor: 9
  }.freeze

  enum dataset: DATASETS
  serialize :data, JSON

  has_one :external_entity, required: false, dependent: :destroy
  has_one :external_relationship, required: false, dependent: :destroy

  # Rails equivalent of the unique index: index_external_data_on_dataset_and_dataset_id
  validates :dataset, uniqueness: { scope: :dataset_id }

  # helper function to update existing rows. Used by importer scripts.
  def merge_data(d)
    if data.nil?
      self.data = d
    elsif data.is_a? Hash
      self.data = data.merge(d)
    else
      raise Exceptions::LittleSisError, 'Incorrectly serialized data attribute'
    end
    self
  end

  def external_relationship?
    Datasets.relationships.include? dataset
  end

  def external_entity?
    Datasets.entities.include? dataset
  end

  # Used primarily by the /external_data/<dataset> route
  def datatables_json
    as_json.tap do |json|
      # Datasets have data wrappers which add additional functionality.
      # Some of those implement a method `nice`, a hash with formatted fields,
      # used by the views or javascript.
      json.store('nice', wrapper.nice) if wrapper.respond_to?(:nice)

      if external_relationship?
        json.store 'external_relationship_id', external_relationship&.id
        json.store 'matched', external_relationship&.matched?
        json.store 'entity1_id', external_relationship&.entity1_id
        json.store 'entity2_id', external_relationship&.entity2_id
      else
        json.store 'external_entity_id', external_entity&.id
        json.store 'matched', external_entity&.matched?
      end
    end
  end

  # Wraps `data` by calling .new(data) with the class at ExternalData::Datasets::<DatasetName>
  # If no wrapper is defined, then `data` is returned
  def data_wrapper
    return @data_wrapper if defined?(@data_wrapper)

    begin
      @data_wrapper = Datasets.const_get(dataset.classify).new(data)
    rescue NameError
      @data_wrapper = data
    end
  end

  alias wrapper data_wrapper

  # updates data['contributions'] by querying ExternalData.fec_contribution
  def update_fec_donor_data!
    verify_dataset 'fec_donor'

    aggregator = proc do |cmte_id, arr|
      {
        committee_name: ExternalData.fec_committee.find_by(dataset_id: cmte_id)&.wrapper&.name,
        committee_id: cmte_id,
        amount: arr.lazy.map(&:wrapper).map(&:amount).sum,
        count: arr.length,
        date_range: arr.lazy.map(&:wrapper).map(&:date).sort.values_at(0, arr.length - 1)
      }
    end

    merge_data('contributions' => ExternalData
                                    .fec_contribution
                                    .where(dataset_id: wrapper.sub_ids)
                                    .to_a
                                    .group_by { |contribution| contribution.wrapper.committee_id }
                                    .map(&aggregator))
  end

  def create_donor_from_self
    verify_dataset 'fec_contribution'

    return if wrapper.name.blank? || wrapper.sub_id.blank?

    fec_donor = ExternalData.fec_donor.find_or_initialize_by(dataset_id: wrapper.digest)

    if fec_donor.persisted? && !fec_donor.wrapper.sub_ids.include?(wrapper.sub_id)
      fec_donor.data['sub_ids'] << wrapper.sub_id
    else
      fec_donor.data = wrapper.donor_attributes.merge({ 'sub_ids' => [], 'contributions' => nil, 'total_contributed' => nil })
    end

    fec_donor.save!
  end

  def verify_dataset(expected)
    raise TypeError, 'called on invalid dataset type' unless dataset == expected
  end

  private :verify_dataset

  #------------- class methods --------------------------------------------------------------------------

  def self.dataset_count
    @enum_lookup ||= DATASETS.invert.freeze

    connection.exec_query(<<~SQL).map { |h| h.merge!('dataset' => @enum_lookup[h['dataset']]) }
      SELECT dataset, COUNT(*) as count
      FROM external_data
      GROUP BY dataset
    SQL
  end

  def self.dataset?(x)
    Datasets.names.include? x.to_s.downcase
  end

  # This is the backend for a datatables.js table.
  # Each dataset has it's on table. Table rows can ordered and filtered.
  # Some datasets use Manticore (ExternalDataSphinxQuery), others use mysql (ExternalDataMysqlQuery)
  # Datatables::Params --> Datatables::Response
  def self.datatables_query(params)
    if params.dataset == 'nys_disclosure' || (params.dataset == 'fec_donor' && params.search_requested?)
      ExternalDataSphinxQuery.run(params)
    else
      ExternalDataMysqlQuery.run(params)
    end
  end

  def self.matched(dataset)
    if Datasets.relationships.include?(dataset)
      joins(:external_relationship).where('external_relationships.relationship_id IS NOT NULL')
    else
      joins(:external_entity).where('external_entities.entity_id IS NOT NULL')
    end
  end

  def self.unmatched(dataset)
    if Datasets.relationships.include?(dataset)
      joins(:external_relationship).where('external_relationships.relationship_id IS NULL')
    else
      joins(:external_entity).where('external_entities.entity_id IS NULL')
    end
  end

  def self.common_fec_contributions
    fec_contribution.where(:TRANSACTION_TP => %i[committee earmarked pacs])
  end

  def self.stats(dataset)
    verify_dataset!(dataset)

    Stats.new(name: dataset,
              description: Datasets.descriptions.fetch(dataset),
              total: public_send(dataset).count,
              matched: public_send(dataset).matched(dataset).count,
              unmatched: public_send(dataset).unmatched(dataset).count)
  end

  private_class_method def self.verify_dataset!(x)
    unless dataset?(x)
      raise Exceptions::LittleSisError # , "Invalid Dataset: #{x}"
    end
  end
  end
