# frozen_string_literal: true

class Position < ApplicationRecord
  has_paper_trail on: [:update, :destroy], versions: { class_name: 'ApplicationVersion' }

  belongs_to :relationship, inverse_of: :position

  def self.description_indicates_board_membership(description)
    str = description.upcase
    return true if str.include?('MEMBER') || str.include?('CHAIRMAN')
    return true if str.include?('DIRECTOR') && !str.include?('DIRECTOR OF')

    false
  end

  def self.description_indicates_executive(description)
    str = description.upcase
    return true if str.include?('CHIEF')
    return true if str.include?('EXECUTIVE') && !str.include?('NON-EXECUTIVE')

    %w[CEO COO CCO CFO CIO CBO CAO CTO CLO CPO CRO CSO].each do |title|
      if str == title || str.include?(" #{title}") || str.include?("#{title} ")
        return true
      end
    end

    false
  end
end
