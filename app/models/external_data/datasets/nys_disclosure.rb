# frozen_string_literal: true

class ExternalData
  module Datasets
    class NYSDisclosure < SimpleDelegator
      SCOPE = {
        include: %i[external_relationship],
        select: "external_data.*,
                 JSON_VALUE(nys_filers.data, '$.name') AS filer_name,
                 nys_filers.dataset_id AS filer_id",
        joins: "LEFT JOIN external_data AS nys_filers
                ON nys_filers.dataset = 5 AND nys_filers.dataset_id = JSON_VALUE(external_data.data, '$.FILER_ID')"
      }.freeze

      def self.with_nys_filer_attributes
        ExternalData.nys_disclosure
          .select(SCOPE[:select])
          .joins(SCOPE[:joins])
      end

      def filer_record
        @filer_record ||= Datasets::NYSFiler.find_by_filer_id(filer_id)
      end

      def filer_name
        if filer_record&.data&.key?('name')
          OrgName.format filer_record.data['name']
        end
      end

      def filer_id
        self['FILER_ID']
      end

      def amount
        self['AMOUNT_70'].to_i if self['AMOUNT_70'].present?
      end

      def amount_str
        "$#{amount.to_s(:delimited)}" if amount.present?
      end

      def date
        Date.strptime(self['DATE1_10'], '%m/%d/%Y').strftime('%Y-%m-%d')
      rescue ArgumentError
        nil
      end

      def name
        if self['CORP_30'].present?
          OrgName.format(self['CORP_30'])
        elsif self['LAST_NAME_44'].present?
          NameParser.format values_at('FIRST_NAME_40', 'MID_INIT_42', 'LAST_NAME_44').join(' ')
        else
          '?'
        end
      end

      def donor_primary_ext
        if self['CORP_30'].present?
          'Org'
        else
          'Person'
        end
      end

      def recipient_primary_ext
        if filer_record.data['committee_type'].to_i == 1
          'Person'
        else
          'Org'
        end
      end

      def tcode
        self['TRANSACTION_CODE']
      end

      def transaction_code
        description = if %w[A B C D].include?(tcode)
                        'Contribution'
                      elsif tcode == 'F'
                        'Expenditure/Payment'
                      else
                        'Other Transaction'
                      end

        "#{description} (#{tcode})"
      end

      def title
        [name, transaction_code, amount_str, filer_name].compact.join(' - ')
      end

      def nice
        @nice ||= {
          'amount' => amount,
          'date' => date,
          'title' => title,
          'transaction_code' => transaction_code,
          'amount_str' => amount_str
        }
      end

      # Used by ExternalRelationshipPresenter
      def data_summary
        {
          'Amount' => amount_str,
          'Donor' => name,
          'Recipient' => filer_name,
          'Date' => date
        }
      end
    end
  end
end
