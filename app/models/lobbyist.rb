class Lobbyist < ApplicationRecord
  include SingularTable

  belongs_to :entity, inverse_of: :lobbyist
end