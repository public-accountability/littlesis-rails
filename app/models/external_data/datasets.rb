# frozen_string_literal: true

class ExternalData
  module Datasets
    def self.relationships
      ['iapd_schedule_a', 'nys_disclosure'].freeze
    end

    def self.entities
      @entities ||= (names - relationships).freeze
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
        nycc: 'New York City Council Members',
        nys_disclosure: 'New York State Campaign Contributions',
        nys_filer: 'New York State Campaign Finance Committees'
      }.with_indifferent_access.freeze
    end

    # Class for each dataset.

    class NYCC < SimpleDelegator
      def self.search(params)
        ExternalData
          .nycc
          .where("JSON_VALUE(data, '$.FullName') like ?", params.query_string)
          .order(params.order_hash)
      end
    end

    class IapdAdvisors < SimpleDelegator
      def self.search(params)
        ExternalData
          .iapd_advisors
          .where("JSON_SEARCH(data, 'one', ?, null, '$.names') iS NOT NULL", params.query_string)
          .ordaer(params.order_hash)
      end
    end

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

      def self.search(params)
        ExternalData
          .iapd_schedule_a
          .where("JSON_SEARCH(data, 'one', ?, null, '$.records[*].name') IS NOT NULL", params.query_query)
          .order(params.order_hash)
      end
    end

    # TODO: combine with NYSFilerImporter::HEADERS
    NYS_FILER_HEADERS = %i[filer_id name filer_type status committee_type office district treas_first_name treas_last_name address city state zip].freeze

    NYSFiler = Struct.new(*NYS_FILER_HEADERS, keyword_init: true) do
      def initialize(data)
        super(**data.symbolize_keys)
      end

      def individual_campaign_committee?
        committee_type == '1'
      end

      def nice
        @nice ||= {
          filer_id: filer_id,
          name: OrgName.format(name),
          committee_type:  NYSCampaignFinance.committee_type_description(committee_type),
          status: status.titleize,
          office: NYSCampaignFinance::OFFICES[office.to_i],
          district: district,
          address: [address, city, state, zip].join(', ')
        }
      end

      def reference_url
        "https://cfapp.elections.ny.gov/ords/plsql_browser/getfiler2_loaddates?filerid_IN=#{filer_id}"
      end

      def self.search(params)
        ExternalData
          .nys_filer
          .where("JSON_VALUE(data, '$.name') like ?", params.query_string)
          .order(params.order_hash)
      end
    end

    class NYSDisclosure < SimpleDelegator
      def amount
        data['AMOUNT_70'].to_i
      end

      def date
        LsDate.transform_date data['DATE1_10']
      end

      def self.search(params)
        raise NotImplementedError
      end
    end
  end
end
