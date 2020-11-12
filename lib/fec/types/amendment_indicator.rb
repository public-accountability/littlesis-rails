# frozen_string_literal: true

module FEC
  module Types
    class AmendmentIndicator < Base
      self.map = {
        'N' => :new,
        'A' => :amendment,
        'T' => :termination
      }.freeze
    end
  end
end
