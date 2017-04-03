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

# Relationships display

  def section_heading(links)
    content_tag(:div, links.heading, class: "subsection") if links.count > 0
  end

  def link_to_all(links)
    content_tag :div, class: 'section_meta' do 
      content_tag(:span, "Showing 1-10 of #{links.count} :: ") + link_to('see all', entity_url(:relationships => links.keyword))
    end if links.count > 10
  end

  def section_order(entity)
    section_order_person = [
      'business_positions', 
      'government_positions', 
      'in_the_office_positions', 
      'other_positions_and_memberships', 
      'schools', 
      'holdings', 
      'services_transactions', 
      'family', 
      'professional_relationships', 
      'friendships', 
      'donors', 
      'donation_recipients', 
      'staff',
      'political_fundraising_committees',
      'miscellaneous'
    ]
    section_order_org = [
      'parents', 
      'children', 
      'other_positions_and_memberships', 
      'staff'
    ]

    entity.person? ? section_order_person : section_order_org
  end

  def extra_links_count(links)
    return '' if links.count <= 1
    "[+#{links.count - 1}]"
  end
end
