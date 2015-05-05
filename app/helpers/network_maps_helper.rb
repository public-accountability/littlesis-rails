module NetworkMapsHelper
  def network_map_link(map)
    link_to(map.name, map_path(map))
  end
end