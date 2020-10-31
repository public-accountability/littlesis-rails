# frozen_string_literal: true

module FEC
  class Committee < ApplicationRecord
    self.primary_key = 'rowid'

    attribute :CMTE_TP, FEC::Types::Committee.new

    belongs_to :candidate, -> { where(:FEC_YEAR => self.FEC_YEAR) }, foreign_key: 'CAND_ID'

    has_many :individual_contributions, foreign_key: 'CMTE_ID', inverse_of: :committee
    # has_many :expenditures, foreign_key: 'CMTE_ID', inverse_of: :committee

    # def committee_type
    #   attributes['CMTE_TP']
    # end

    # def name
    #   attributes['CMTE_NM']
    # end

    # def committee_id
    #   attributes['CMTE_ID']
    # end

    # def name_and_id
    #   { name: name, id: committee_id }
    # end

    # def contributions_total
    #   contributions.sum('TRANSACTION_AMT')
    # end

    # def self.super_pacs
    #   where 'CMTE_TP' => 'O'
    # end

    # def self.find_by_id(id)
    #   find_by 'CMTE_ID' => id
    # end

    # def self.search_by_name(name)
    #   where 'CMTE_NM like ?', "%#{name.upcase}%"
    # end

    # def self.trump_pac
    #   find_by_id 'C00618371'
    # end

    # def self.api
    #   find_by_id 'C00483677'
    # end
  end
end
