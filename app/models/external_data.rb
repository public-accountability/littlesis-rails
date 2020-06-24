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
  DATASETS = { reserved: 0,
               iapd_advisors: 1,
               iapd_schedule_a: 2,
               nycc: 3 }.freeze

  enum dataset: DATASETS
  serialize :data, JSON

  module Datasets
    IapdScheduleA = Struct.new(:records, :advisor_crd_number, :advisor_name, :owner_name, :title, :owner_primary_ext, :last_record, keyword_init: true) do
      def initialize(data)
        records = data['records'].sort_by { |record| record['filename'] }
        owner_primary_ext = records.last['owner_type'] == 'I' ? 'Person' : 'Org'

        super(records: records,
              advisor_crd_number: data.fetch('advisor_crd_number'),
              advisor_name: data.fetch('advisor_name'),
              owner_name: records.last['name'],
              title: records.last['title_or_status'],
              owner_primary_ext: owner_primary_ext,
              last_record: records.last)
      end

      def min_acquired
        LsDate.parse(records.map { |r| r['acquired'] }.min)
      end

      def format_name
        if owner_primary_ext == 'Person'
          NameParser.format(owner_name)
        else
          OrgName.format(owner_name)
        end
      end
    end

    def self.relationships
      ['iapd_schedule_a']
    end

    def self.entities
      @entities ||= (names - relationships)
    end

    def self.names
      @names ||= ExternalData::DATASETS.keys.without(:reserved).map(&:to_s).freeze
    end

    def self.inverted_names
      @inverted_names ||= names.invert.freeze
    end

    def self.descriptions
      @descriptions ||= {
        iapd_advisors: 'Investor Advisor corporations registered with the SEC',
        iapd_schedule_a: 'Owners and board members of investor advisors',
        nycc: 'New York City Council Members'
      }.with_indifferent_access.freeze
    end
  end

  Stats = Struct.new(:name, :description, :total, :matched, :unmatched, keyword_init: true) do
    def percent_matched
      ((matched / total.to_f) * 100).round(1)
    end

    def url
      Rails.application.routes.url_helpers.dataset_path(dataset: name, matched: 'unmatched')
    end
  end

  has_one :external_entity, required: false, dependent: :destroy
  has_one :external_relationship, required: false, dependent: :destroy

  # Rails equivalent of the unique index: index_external_data_on_dataset_and_dataset_id
  validates :dataset, uniqueness: { scope: :dataset_id }

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

  def datatables_json
    as_json(only: %i[id data dataset]).tap do |json|
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
    if defined?(@data_wrapper)
      @data_wrapper
    elsif Datasets.const_defined?(dataset.classify)
      @data_wrapper = Datasets.const_get(dataset.classify).new(data)
    else
      @data_wrapper = data
    end
  end

  alias wrapper data_wrapper

  def self.dataset_count
    connection.exec_query(<<~SQL).map { |h| h.merge!('dataset' => Datasets.inverted_names[h['dataset']]) }
      SELECT dataset, COUNT(*) as count
      FROM external_data
      GROUP BY dataset
    SQL
  end

  def self.dataset?(x)
    Datasets.names.include? x.to_s.downcase
  end

  # This is the backend for the external data overview table
  # input: Datatables::Params
  def self.datatables_query(params)
    relation = if params.search_requested?
                 dataset_search(params)
               else
                 public_send(params.dataset)
               end

    if %i[matched unmatched].include? params.matched
      relation = relation.public_send(params.matched, params.dataset)
    end

    Datatables::Response.new(draw: params.draw).tap do |response|
      response.recordsTotal = records_total(params.dataset)
      response.recordsFiltered = relation.count
      response.data = relation.to_datatables_array(params)
    end
  end

  # +params+ should be a Datatables::Params (or have two attributes/methods: search_value, dataset)
  def self.dataset_search(params)
    query = "%#{params.search_value}%"

    case params.dataset
    when 'nycc'
      nycc
        .where("JSON_VALUE(data, '$.FullName') like ?", query)
        .order(params.order_hash)
    when 'iapd_advisors'
      iapd_advisors
        .where("JSON_SEARCH(data, 'one', ?, null, '$.names') iS NOT NULL", query)
        .order(params.order_hash)
    when 'iapd_schedule_a'
      iapd_schedule_a
        .where("JSON_SEARCH(data, 'one', ?, null, '$.records[*].name') IS NOT NULL", query)
        .order(params.order_hash)
    else
      raise NotImplementedError
    end
  end

  def self.to_datatables_array(params)
    preload(:external_entity, :external_relationship)
      .offset(params.start)
      .limit(params.length)
      .to_a
      .map(&:datatables_json)
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

  def self.stats(dataset)
    verify_dataset!(dataset)

    Stats.new(name: dataset,
              description: Datasets.descriptions.fetch(dataset),
              total: records_total(dataset),
              matched: public_send(dataset).matched(dataset).count,
              unmatched: public_send(dataset).unmatched(dataset).count)
  end

  # For data exploration and testing
  def self.random_iapd_schedule_a_records(take = 100)
    iapd_schedule_a
      .order('RAND()')
      .pluck(:data)
      .take(take)
      .map { |r| r['records'] }
      .flatten
  end

  private_class_method def self.records_total(dataset)
    class_eval "#{dataset}.count"
  end

  private_class_method def self.verify_dataset!(x)
    unless dataset?(x)
      raise Exceptions::LittleSisError # , "Invalid Dataset: #{x}"
    end
  end
end
