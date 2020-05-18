# frozen_string_literal: true

module ExternalEntitiesHelper
  def external_entities_tab(id, active = false)
    class_name = active ? 'tab-pane active' : 'tab-pane'
    content_tag(:div, id: id, class: class_name, role: 'tabpanel') { yield }
  end
end
