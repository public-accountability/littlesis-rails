module HomeHelper
  # input: <NetworkMap>
  # output: Str
  # If the map thumbnail is missing, it returns the default image path
  def networkmap_image_path(map)
    return asset_path 'netmap-org.png' if map.thumbnail.blank?
    map.thumbnail
  end
end
