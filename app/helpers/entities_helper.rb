module EntitiesHelper

  def entity_hash_link(entity, name=nil, action=nil)
    name ||= entity['name']
    link_to name, Entity.legacy_url(entity['primary_ext'], entity['id'], name, action)
  end

  def tiny_entity_image(entity)
    content_tag('div', nil, class: "entity_tiny_image", style: "background-image: url('#{image_path(entity.featured_image_url('small'))}');")
  end

  def legacy_user_path(user)
    '/user/' + user.username
  end

  
  def active_tab?(tab_name, active_tab)
    if active_tab == tab_name
      return 'active'
    else
      return 'inactive'
    end
  end
  
  # <Entity> -> html
  def type_select_boxes(entity = @entity)
    content_tag(:div, class: 'row', id: 'entity-types') do
      checkboxes(entity).each_slice(5).reduce('') do |x, box_group|
        x + content_tag(:div, box_group.reduce(:+), class: 'col-sm-4')
      end.html_safe
    end
  end

  # <Entity> -> [ content_tag ] 
  def checkboxes(entity)
    checked_def_ids = entity.extension_records.map(&:definition_id)
    ExtensionDefinition.send("#{entity.primary_ext.downcase}_types").collect do |ed|
      is_checked = checked_def_ids.include?(ed.id)
      glyph_checkbox(is_checked) + content_tag(:span, " #{ed.display_name}")+ tag(:br)
    end
  end
  
  # boolean, [] -> content_tag
  def glyph_checkbox(checked = false, glyphicon_class = ['glyphicon'])
    glyphicon_class.append(if checked then 'glyphicon-check' else 'glyphicon-unchecked' end)
    content_tag(:span, nil, { 'class' => glyphicon_class, 'aria-hidden' => 'true' })
  end
  
end
