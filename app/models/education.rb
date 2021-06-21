# frozen_string_literal: true

class Education < ApplicationRecord
  belongs_to :relationship, inverse_of: :education, optional: true
  belongs_to :degree, optional: true

  has_paper_trail on: [:update, :destroy]

  SELECT_OPTIONS = ['Undergraduate', 'Graduate', 'High School'].freeze
end
