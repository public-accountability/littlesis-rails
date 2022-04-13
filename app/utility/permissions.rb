# frozen_string_literal: true

class Permissions
  ACCESS_OPEN = 0
  ACCESS_CLOSED = 1
  ACCESS_PRIVATE = 2

  ACCESS_MAPPING = {
    0 => 'Open',
    1 => 'Closed',
    2 => 'Private'
  }.freeze
end
