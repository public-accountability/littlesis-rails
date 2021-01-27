# frozen_string_literal: true

module ExternalDataset
  class NYCCGrid < BaseGrid
    scope do
      ExternalDataset::NYCC.all
    end

    filter(:name, :string) { |value| where("full_name LIKE ?", "%#{value}%") }

    column(:council_district)
    column(:full_name)
    column(:email)
    column(:party)
  end
end
