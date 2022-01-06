# frozen_string_literal: true

class Donation < ApplicationRecord
  belongs_to :relationship, inverse_of: :donation

  # has_many :os_matches, inverse_of: :donation

  has_paper_trail on: [:update, :destroy], versions: { class_name: 'ApplicationVersion' }
end
