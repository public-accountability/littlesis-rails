# frozen_string_literal: true

class HelpPage < ApplicationRecord
  include EditablePage

  has_paper_trail on: %i[create destroy update]
  has_rich_text :content
end
