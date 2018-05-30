# frozen_string_literal: true

class Position < ApplicationRecord
  include SingularTable
  
  has_paper_trail on: [:update, :destroy]
  
  belongs_to :relationship, inverse_of: :position
end
