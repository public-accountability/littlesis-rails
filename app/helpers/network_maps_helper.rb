# frozen_string_literal: true

module NetworkMapsHelper
  def oligrapher_js_tags
    content_tag(:script, nil, src: "/js/oligrapher/oligrapher-#{NetworkMap::OLIGRAPHER_VERSION}.js") +
    content_tag(:script, nil, src: "/js/oligrapher/oligrapher_littlesis_bridge-#{NetworkMap::OLIGRAPHER_VERSION}.js")
  end

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

  def network_map_feature_btn(map)
    icon_class = map.is_featured ? 'featured-map-star' : 'not-featured-map-star'
    form_tag(feature_map_path(map), id: "feature-map-form-#{map.id}") do
      hidden_field_tag('map[feature_action]', (map.is_featured ? 'REMOVE' : 'ADD')) +
        button_tag(type: 'submit', class: 'featured-map-star-button') { content_tag :span, nil, class: icon_class }
    end
  end
end
