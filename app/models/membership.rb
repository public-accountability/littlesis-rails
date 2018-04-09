# frozen_string_literal: true

class Membership < ApplicationRecord
  include SingularTable
  serialize :elected_term, OpenStruct

  has_paper_trail on: [:update, :destroy]
  belongs_to :relationship, inverse_of: :membership
end
