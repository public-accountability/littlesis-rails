# frozen_string_literal: true

class Link
  module Sorting
    def self.by_featured(a, b)
      if a.relationship.is_featured && b.relationship.is_featured
        0
      elsif a.relationship.is_featured
        1
      elsif b.relationship.is_featured
        -1
      end
    end

    def self.by_amount(a, b)
      a_amount = a.relationship.amount
      b_amount = b.relationship.amount

      if a_amount.present? && b_amount.present?
        a_amount <=> b_amount
      elsif a_amount.present? && b_amount.nil?
        1
      elsif b_amount.present? && a_amount.nil?
        -1
      end
    end

    def self.by_is_current(a, b)
      if a.relationship.is_current && b.relationship.is_current
        0
      elsif a.relationship.is_current == true && !b.relationship.is_current
        1
      elsif b.relationship.is_current == true && !a.relationship.is_current
        -1
      end
    end

    def self.by_startdate(a, b)
      if a.relationship.start_date && b.relationship.start_date
        a.relationship.start_date <=> b.relationship.start_date
      end
    end
  end
end
