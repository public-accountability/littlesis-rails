# frozen_string_literal: true

module FEC
  module DataCleaner
    def self.run
      Committee.where("CAND_ID = ''").update_all(:CAND_ID => nil)
    end
  end
end
