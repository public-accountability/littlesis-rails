# frozen_string_literal: true

class AddressState < ApplicationRecord
  include SingularTable

  has_many :addresses, inverse_of: :state, dependent: :destroy

  def self.abbreviation_map
    return @abbreviation_map if defined?(@abbreviation_map)
    @abbreviation_map = all.each_with_object({}) do |state, hash|
      hash[state.abbreviation] = state.name
    end
  end
end
