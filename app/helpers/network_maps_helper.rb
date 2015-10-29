module NetworkMapsHelper
  def smart_map_path(map)
    # map.annotations.empty? ? map_path(map) : story_map_path(map)
    map_path(map)
  end

  def network_map_link(map)
    link_to(map.name, smart_map_path(map))
  end
end