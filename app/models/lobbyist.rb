class Lobbyist < ActiveRecord::Base
  include SingularTable

  belongs_to :entity, inverse_of: :lobbyist
end