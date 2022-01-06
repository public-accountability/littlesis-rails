# frozen_string_literal: true

class Family < ApplicationRecord
  has_paper_trail on: [:update, :destroy], versions: { class_name: 'ApplicationVersion' }
  belongs_to :relationship, inverse_of: :family
end
