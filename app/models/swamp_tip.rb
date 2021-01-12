# frozen_string_literal: true

class SwampTip < ApplicationRecord
  validates :content, presence: true
end
