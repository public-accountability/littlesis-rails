# frozen_string_literal: true

class HelpPage < ApplicationRecord
  include EditablePage

  has_paper_trail on: %i[create destroy update]
end
