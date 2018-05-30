# frozen_string_literal: true

class Page < ApplicationRecord
  include EditablePage

  has_paper_trail on: %i[create destroy update]
end
