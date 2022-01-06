# frozen_string_literal: true

class Ownership < ApplicationRecord
  belongs_to :relationship, inverse_of: :ownership

  has_paper_trail on: [:update, :destroy], versions: { class_name: 'ApplicationVersion' }
end
