class Education < ApplicationRecord
  include SingularTable

  belongs_to :relationship, inverse_of: :education
  belongs_to :degree

  has_paper_trail on: [:update, :destroy]


  SELECT_OPTIONS = ['Undergraduate', 'Graduate', 'High School'].freeze
end
