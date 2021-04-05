# frozen_string_literal: true

class ToolkitPage < ApplicationRecord
  include EditablePage

  has_rich_text :content
end
