# frozen_string_literal: true

class ExternalData
  module Datasets
    class FECCommittee < SimpleDelegator
      def self.import_or_update(fec_committee)
        ExternalData.fec_committee.find_or_initialize_by(dataset_id: fec_committee.CMTE_ID).tap do |ed|
          unless ed.data&.key?('FEC_YEAR') && ed.data.fetch('FEC_YEAR') >= fec_committee.FEC_YEAR
            ed.merge_data(fec_committee.attributes)
          end

          ed.save!
          ed.external_entity || ed.create_external_entity!(dataset: ed.dataset)
          ed.external_entity.automatch_or_create
        end
      end

      def self.search(params)
        ExternalData
          .fec_committee
          .where("JSON_VALUE(data, '$.CMTE_NM') like ?", params.query_string)
          .or(ExternalData.fec_committee.where("JSON_VALUE(data, '$.CMTE_ST1') like ?", params.query_string))
          .or(ExternalData.fec_committee.where("JSON_VALUE(data, '$.CONNECTED_ORG_NM') like ?", params.query_string))
        # .order(params.order_hash)
      end

      def name
        self['CMTE_NM']
      end

      def committee_id
        self['CMTE_ID']
      end
    end
  end
end
