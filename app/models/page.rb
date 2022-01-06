# frozen_string_literal: true

class Page < ApplicationRecord
  include EditablePage

  has_paper_trail on: %i[create destroy update], versions: { class_name: 'ApplicationVersion' }
  has_rich_text :content
end
