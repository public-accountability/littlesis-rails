# frozen_string_literal: true

module ExternalEntitiesHelper
  def render_columns_js(dataset)
    render partial: "external_entities/dataset_columns/#{dataset}", formats: [:js]
  end

  def external_entities_tab(id, active = false)
    class_name = active ? 'tab-pane active' : 'tab-pane'
    content_tag(:div, id: id, class: class_name, role: 'tabpanel') { yield }
  end
end
