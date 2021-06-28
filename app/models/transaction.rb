class Transaction < ApplicationRecord
  belongs_to :relationship, inverse_of: :trans

  has_paper_trail on: [:update, :destroy]
end
