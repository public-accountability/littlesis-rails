class Family < ApplicationRecord
  has_paper_trail on: [:update, :destroy]
  belongs_to :relationship, inverse_of: :family
end
