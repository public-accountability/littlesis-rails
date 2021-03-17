# frozen_string_literal: true

module CmpNetworkMapService
  CMP_USER_ID = 11_276
  LIMIT = 4

  def self.random_map_pairs
    maps = random_maps
    [maps[0..1], maps[2..4]]
  end

  def self.random_maps
    User
      .find(CMP_USER_ID)
      .network_maps
      .where(is_private: false)
      .order(Arel.sql('RANDOM()'))
      .limit(LIMIT)
      .to_a
  end
end
