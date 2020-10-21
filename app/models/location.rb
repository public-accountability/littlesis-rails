# frozen_string_literal: true

class Location < ApplicationRecord
  belongs_to :entity, optional: false
  has_one :address, dependent: :destroy
end
