class Donation < ApplicationRecord
  belongs_to :relationship, inverse_of: :donation

  # has_many :os_matches, inverse_of: :donation

  has_paper_trail on: [:update, :destroy]
end
