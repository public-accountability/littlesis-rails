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

  def get_relationship_section_links(section)
    instance_variable_get("@#{section}")
  end

  def get_relationship_section_heading(section)
    @sections[section]
  end

  def display_relationship_section_heading(links_count, section)
    if links_count > 0
      content_tag(:div, get_relationship_section_heading(section), class: "subsection")
    end
  end

end
