module HomeHelper
  # input: <NetworkMap>
  # output: Str
  # If the map thumbnail is missing, it returns the default image_path
  def networkmap_image_path(map)
    return image_path 'netmap-org.png' if map.thumbnail.blank?
    map.thumbnail
  end
end
