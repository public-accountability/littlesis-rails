# frozen_string_literal: true

module NetworkMapsHelper
  # used on /maps and user pages
  def network_map_link(map)
    link = link_to(raw(map.name), oligrapher_url(map))
    return link unless map.is_private
    link + tag('i', class: "bi bi-lock-fill private-network-map-icon pl-1")
  end

  def network_map_feature_btn(map)
    return tag.i(class: 'bi bi-lock-fill') if map.is_private

    icon_class = map.is_featured ? 'star' : 'not-star'
    button_title = map.is_featured ? 'unfeature this map' : 'feature this map'

    form_tag(feature_map_path(map), id: "feature-map-form-#{map.id}", class: 'd-inline') do
      hidden_field_tag('map[feature_action]', (map.is_featured ? 'REMOVE' : 'ADD')) +
        button_tag(type: 'submit', class: 'star-button', title: button_title) { content_tag :span, nil, class: icon_class }
    end
  end
end
