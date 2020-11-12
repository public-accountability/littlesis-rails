# frozen_string_literal: true

module FEC
  class Candidate < ApplicationRecord
    self.primary_key = 'rowid'

    def self.all_candidates
      find_by_sql <<~SQL
        SELECT candidates.* FROM candidates
        GROUP BY CAND_ID
        HAVING FEC_YEAR = MAX(FEC_YEAR)
      SQL
    end

    # # belongs_to :pcc, foreign_key: 'CAND_PCC', optional: true, class_name: 'Committee'

    def incumbent?
      self.CAND_ICI == 'I'
    end

    def challeneger?
      self.CAND_ICI == 'C'
    end

    def open_seat?
      self.CAND_ICI == 'O'
    end

    # def self.search(name)
    #   where 'CAND_NAME LIKE ?', "%#{name}%"
    # end

    # def self.republicans
    #   where 'CAND_PTY_AFFILIATION' => 'REP'
    # end

    # def self.democrats
    #   where 'CAND_PTY_AFFILIATION' => 'DEM'
    # end

    # def self.year(y)
    #   where 'CAND_ELECTION_YR' => y.to_i.to_s
    # end

    # # state is upcase and abbreviated
    # def self.state(st)
    #   where 'CAND_OFFICE_ST' => st.upcase
    # end

    # def self.house_of_representatives
    #   where 'CAND_OFFICE' => 'H'
    # end

    # def self.senate
    #   where 'CAND_OFFICE' => 'S'
    # end

    # def self.find_by_id(id)
    #   find_by 'CAND_ID' => id
    # end
  end
end
