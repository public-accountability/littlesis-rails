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

      def name
        self['CMTE_NM']
      end

      def committee_id
        self['CMTE_ID']
      end
    end
  end
end
