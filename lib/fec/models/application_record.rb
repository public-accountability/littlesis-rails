# frozen_string_literal: true

module FEC
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    def self.set_default_fec_year_scope
      default_scope -> { where(:FEC_YEAR => Fec.default_year) }
    end

    # def readonly?
    #   true
    # end
  end
end
