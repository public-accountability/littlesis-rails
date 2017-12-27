class FecFiling < ApplicationRecord
  include SingularTable

  belongs_to :relationship, inverse_of: :fec_filings
end