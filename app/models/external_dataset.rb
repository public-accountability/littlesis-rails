# frozen_string_literal: true

module ExternalDataset
  TABLE_PREFIX = 'external_data'
  ROOT_DIR = Rails.root.join('data/external_data')
  DATASETS = %i[nycc nyc_contributions nys_disclosures nys_filers fec_candidates fec_committees fec_contributions].freeze

  mattr_reader(:datasets) { DATASETS }

  mattr_reader :descriptions do
    {
      iapd_advisors: 'Investor Advisor Corporations Registered with the SEC',
      iapd_schedule_a: 'Owners and Board Members of Investor Advisors',
      nycc: 'New York City Council Members',
      nyc_contributions: 'New York City Campaign Contributions',
      nys_disclosures: 'New York State Campaign Contributions',
      nys_filers: 'New York State Campaign Finance Committees',
      fec_candidates: 'Candidates for US Federal Office',
      fec_committees: 'Federal Campaign Finance Committees',
      fec_contributions: 'Federal Campaign Finance Individual Contributions'
    }.with_indifferent_access.freeze
  end

  # @param dbname [String]
  # @return [Class]
  def self.fetch_dataset_class(dname)
    raise ArgumentError, "invalid dataset: #{dname}" unless DATASETS.include?(dname.to_sym)

    const_get(dname.to_s.classify)
  end

  # creates shortcuts. For example: ExternalDataset.nys_filers, ExternalDataset.nycc
  DATASETS.each do |dname|
    define_singleton_method(dname) { fetch_dataset_class(dname) }
  end

  module DatasetInterface
    def dataset=(dataset)
      unless ExternalDataset::DATASETS.include?(dataset)
        raise ArgumentError, "invalid dataset: #{dataset}"
      end

      mattr_accessor :dataset_name
      self.dataset_name = dataset
      self.table_name = "#{TABLE_PREFIX}_#{dataset}"
    end

    # interface

    def create_table
      raise NotImplementedError
    end

    def download
      raise NotImplementedError
    end

    def transform
      raise NotImplementedError
    end

    def load
      raise NotImplementedError
    end

    def export
      raise NotImplementedError
    end

    def report
      puts "There are #{ActiveSupport::NumberHelper.number_to_delimited(count)} rows in #{table_name}"
    end

    # utility

    def description
      ExternalDataset.descriptions[dataset_name]
    end

    def run_query(sql)
      Rails.logger.info sql
      ApplicationRecord.connection.exec_query(Arel.sql(sql))
    end

    def random
      order('random()')
    end
  end

  module FECData
    def load
      FECLoader.run(self)
    end
  end

  module YearScopes
    extend ActiveSupport::Concern

    # Creates ActiveRecord scopes -- y22, y20, etc.  -- for filtering by fec_year
    included do
      (10..22).to_a.delete_if(&:odd?).each do |year|
        send :scope, "y#{year}", -> { where(fec_year: "20#{year}".to_i) }
      end
    end
  end
end
