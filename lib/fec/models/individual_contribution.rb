# frozen_string_literal: true

module FEC
  class IndividualContribution < ApplicationRecord
    self.primary_key = 'SUB_ID'
    belongs_to :committee, foreign_key: 'CMTE_ID', class_name: 'Committee', inverse_of: :individual_contributions
    belongs_to :donor, optional: true, inverse_of: :individual_contributions

    attribute :AMNDT_IND, FEC::Types::AmendmentIndicator.new

    # def to_h
    #   {
    #     amount: amount,
    #     election_type: election_type,
    #     report_type: report_type,
    #     transaction_type: transaction_type,
    #     date: attributes['TRANSACTION_DT'].to_s,
    #     contributor: contributor_info,
    #     committee: committee.name_and_id,
    #     transfered_via: transfered_via
    #   }
    # end

    # def amount
    #   attributes['TRANSACTION_AMT'].to_i
    # end

    # def contributor_info
    #   @contributor_info ||= {
    #     name: attributes['NAME'],
    #     city: attributes['CITY'],
    #     state: attributes['STATE'],
    #     zipcode: attributes['ZIP_CODE'],
    #     employer: attributes['EMPLOYER'],
    #     occupation: attributes['OCCUPATION'],
    #     other_id: attributes['OTHER_ID']
    #   }
    # end

    # def amendment_indicator
    #   {
    #     'N' => :new,
    #     'A' => :amendment,
    #     'T' => :termination
    #   }.fetch(attributes['AMNDT_IND'])
    # end

    # def transfered_via
    #   return @transfered_via if defined?(@transfered_via)

    #   @transfered_via = if contributors_fec_id.present?
    #                       Committee.find_by_id(contributors_fec_id)&.name_and_id
    #                     end
    # end

    # def contributors_fec_id
    #   attributes['OTHER_ID']
    # end

    # def election_type
    #   FEC::Types::Election.parse attributes['TRANSACTION_PGI']
    # end

    # def report_type
    #   FEC::Types::Report.parse attributes['RPT_TP']
    # end

    # def transaction_type
    #   FEC::Types::Transaction.parse attributes['TRANSACTION_TP']
    # end

    # def self.default_scope
    #   # Pacs, committee, earmarked
    #   where "TRANSACTION_TP" => %w[10 15 15E 24T 22Y]
    # end

    # def self.new_record
    #   where 'AMNDT_IND' => 'N'
    # end

    # def self.new_amendment
    #   where 'AMNDT_IND' => 'N'
    # end

    # def self.transaction_type_summary
    #   total_count = Contribution.count.to_f

    #   connection.exec_query(
    #     "SELECT TRANSACTION_TP, count(*) as c FROM #{table_name} GROUP BY TRANSACTION_TP ORDER BY c DESC"
    #   ).rows.map do |(transaction_type, row_count)|
    #     {
    #       code: transaction_type,
    #       type: FEC::TransactionType.parse(transaction_type),
    #       count: row_count,
    #       percent: (row_count / total_count).round(2) * 100
    #     }
    #   end
    # end

    # def self.group_by_name_zip_code_employer_occupation
    #   connection.exec_query(<<~SQL).rows
    #     SELECT json_group_array(SUB_ID) as sub_ids, TRIM(NAME) as name, TRIM(ZIP_CODE) as zip_code, TRIM(EMPLOYER) as employer, TRIM(OCCUPATION) as occupation
    #     FROM individual_contributions
    #     GROUP BY TRIM(NAME), TRIM(ZIP_CODE), TRIM(EMPLOYER), TRIM(OCCUPATION)
    #   SQL
    # end
  end
end
