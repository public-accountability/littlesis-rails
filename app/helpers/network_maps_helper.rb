module NetworkMapsHelper
  def smart_map_path(map)
    # map.annotations.empty? ? map_path(map) : story_map_path(map)
    map_path(map)
  end

  # used on /maps and user pages
  def network_map_link(map)
    link = link_to(raw(map.name), smart_map_path(map))
    return link unless map.is_private
    link + content_tag('span', nil, class: "glyphicon glyphicon-lock private-network-map-icon pad-left-05em")
  end
end
