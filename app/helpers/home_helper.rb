# frozen_string_literal: true

module HomeHelper
  # input: <NetworkMap>
  # output: Str
  # If the map thumbnail is missing, it returns the default image path
  def networkmap_image_path(map)
    return asset_path 'netmap-org.png' if map.thumbnail.blank?
    map.thumbnail
  end

  def homepage_headline_h3(text)
    content_tag(:div, class: 'thin-grey-bottom-border mb-3') do
      content_tag(:h3, text)
    end
  end
end
