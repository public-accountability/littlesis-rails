# frozen_string_literal: true

module CmpNetworkMapService
  CMP_USER_ID = 11276
  LIMIT = 4

  def self.random_map_pairs
    maps = random_maps
    [ maps[0..1], maps[2..4] ]
  end

  def self.random_maps
    User
      .find(CMP_USER_ID)
      .network_maps
      .order(Arel.sql('RAND()'))
      .limit(LIMIT)
      .to_a
  end
end
