# frozen_string_literal: true

module ExternalDataset
  TABLE_PREFIX = 'external_data'
  ROOT_DIR = Rails.root.join('data/external_data')
  DATASETS = %i[nycc nyc_contribution nys_disclosures nys_filers fec_candidates fec_committees fec_contribution].freeze

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
      fec_contribution: 'Federal Campaign Finance Individual Contributions',
      fec_donor: 'Donors Extracted from FEC Individual Contributions'
    }.with_indifferent_access.freeze
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

    def self.create_table
      raise NotImplementedError
    end

    def download
      raise NotImplementedError
    end

    def extract
      raise NotImplementedError
    end

    def load
      raise NotImplementedError
    end

    def export
      raise NotImplementedError
    end

    def report
      puts "There are #{count} rows in #{table_name}"
    end

    # utility

    def description
      ExternalDataset.descriptions[dataset_name]
    end

    def run_query(sql)
      Rails.logger.info sql
      ApplicationRecord.connection.exec_query(Arel.sql(sql))
    end
  end

  module FECData
    # use FEC::Cli to download and extract FEC data
    def load
      FECLoader.run(self)
    end
  end
end
