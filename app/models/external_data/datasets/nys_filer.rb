# frozen_string_literal: true

class ExternalData
  module Datasets
    # TODO: combine with NYSFilerImporter::HEADERS
    NYS_FILER_HEADERS = %i[filer_id name filer_type status committee_type office district treas_first_name treas_last_name address city state zip].freeze

    NYSFiler = Struct.new(*NYS_FILER_HEADERS, keyword_init: true) do
      def initialize(data)
        super(**data.symbolize_keys)
      end

      def individual_campaign_committee?
        committee_type == '1'
      end

      def office_description
        NYSCampaignFinance::OFFICES[office.to_i]
      end

      def committee_type_description
        NYSCampaignFinance.committee_type_description(committee_type)
      end

      def nice
        @nice ||= {
          filer_id: filer_id,
          name: OrgName.format(name),
          committee_type: committee_type_description,
          status: status.titleize,
          office: office_description,
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

      def self.find_by_filer_id(filer_id)
        ExternalData
          .nys_filer
          .select("*, JSON_VALUE(data, '$.name') as filer_name, dataset_id as filer_id")
          .find_by(dataset_id: filer_id)
      end

      def self.json
        ExternalData.nys_filer.pluck(:data)
      end
    end
  end
end
