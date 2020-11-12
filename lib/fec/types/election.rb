# frozen_string_literal: true

module FEC
  module Types
    class Election < Base
      self.map = {
        'P' => :primary,
        'G' => :general,
        'O' => :other,
        'C' => :convention,
        'R' => :runoff,
        'S' => :special,
        'E' => :recount
      }
    end
  end
end
