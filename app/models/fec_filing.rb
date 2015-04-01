class FecFiling < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :fec_filings
end