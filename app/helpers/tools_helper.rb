# frozen_string_literal: true

module ToolsHelper
  # Creates <select> html with relationship category options
  #--------------
  # Adds  'unofficial' Relationship category options: 30 & 31, 50 & 51
  #
  # 50 represents "Donations Received" where the selected entity is entity2
  # 51 represents "Donations Given" where the selected entity is entity1
  #
  # 30 represents "Memberships" where the selected entity is entity1
  # 31 represents "Members" where the selected entity is entity2
  def relationship_select_builder(entity)
    content_tag(:select, id: 'relationship-cat-select') do
      Relationship
        .categories_for(entity.primary_ext)
        .reject { |c| c == 5 || c == 3 }
        .map { |c| content_tag(:option, Relationship.category_display_name(c), value: c) }
        .unshift(content_tag(:option, ''))
        .push(content_tag(:option, 'Donations Received', value: 50))
        .push(content_tag(:option, 'Donations Given', value: 51))
        .push(content_tag(:option, 'Memberships', value: 30))
        .push(entity.org? ? content_tag(:option, 'Members', value: 31) : nil)
        .compact
        .reduce(:+)
    end
  end

  # em = @entity_merger
  def em_prop(prop)
    @entity_merger.send(prop)
  end

  def unless_em_prop_is_empty(prop)
    yield unless em_prop(prop).empty?
  end
end
