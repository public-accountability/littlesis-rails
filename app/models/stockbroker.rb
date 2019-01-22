# frozen_string_literal: true

class Stockbroker < ApplicationRecord
  belongs_to :entity, inverse_of: :stockbroker
end
