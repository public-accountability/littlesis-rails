# frozen_string_literal: true

module FEC
  class Organization < ApplicationRecord
    has_many :donors, through: :donor_employers
    # has_many :operating_expenditure through: :organization_operating_expenditures
  end
end
