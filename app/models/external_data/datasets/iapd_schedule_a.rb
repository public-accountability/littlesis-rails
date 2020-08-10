# frozen_string_literal: true

class ExternalData
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

      def self.search(params)
        ExternalData
          .iapd_schedule_a
          .where("JSON_SEARCH(data, 'one', ?, null, '$.records[*].name') IS NOT NULL", params.query_string)
          .order(params.order_hash)
      end
    end
  end
end
