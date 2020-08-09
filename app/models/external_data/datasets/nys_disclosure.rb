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

      def amount
        self['AMOUNT_70'].to_i if self['AMOUNT_70'].present?
      end

      def date
        Date.strptime(self['DATE1_10'], '%m/%d/%Y').strftime('%Y-%m-%d')
      rescue ArgumentError
        nil
      end

      def title
        name = if self['CORP_30'].present?
                 OrgName.format(self['CORP_30'])
               elsif self['LAST_NAME_44'].present?
                 NameParser.format values_at('FIRST_NAME_40', 'MID_INIT_42', 'LAST_NAME_44').join(' ')
               else
                 '?'
               end

        transaction = if %w[A B C D].include? self['TRANSACTION_CODE']
                        ' - Contribution'
                      elsif self['TRANSACTION_CODE'] == 'F'
                        ' - Expenditure/Payment'
                      else
                        ' - Other Transaction'
                      end

        fmt_amount = amount.present? ? " - $#{amount.to_s(:delimited)}" : ''

        "#{name}#{transaction}#{fmt_amount}"
      end

      def nice
        @nice ||= {
          'amount' => amount,
          'date' => date,
          'title' => title
        }
      end
    end
  end
end
