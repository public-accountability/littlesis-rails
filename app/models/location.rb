# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :entity, optional: false
  has_one :address, dependent: :destroy

  enum region: { 'Global' => 0,
                 'Africa' => 1,
                 'Asia' => 2,
                 'Australia and Oceania' => 3,
                 'Europe' => 4,
                 'Latin America and Caribbean' => 5,
                 'Middle East' => 6,
                 'US and Canada' => 7 }
end
