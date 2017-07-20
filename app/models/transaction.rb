class Transaction < ActiveRecord::Base
  include SingularTable

  belongs_to :relationship, inverse_of: :trans

  has_paper_trail on: [:update, :destroy]
end
