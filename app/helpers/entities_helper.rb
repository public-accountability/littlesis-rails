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

  def get_other_positions_and_memberships_heading(positions_count, other_positions_and_memberships_count)
    return 'Memberships' if positions_count == 0
    return 'Positions & Memberships' if positions_count == other_positions_and_memberships_count
    return 'Other Positions & Memberships'
  end

  def display_relationship_section_heading(links_count, pos_count, other_pos_count, section)
    headings = {
      'staff' =>                           'Office/Staff',
      'business_positions' =>              'Business Positions',
      'government_positions' =>            'Government Positions',
      'in_the_office_positions' =>         'In The Office Of',
      'other_positions_and_memberships' =>  get_other_positions_and_memberships_heading(pos_count, other_pos_count),
      'schools' =>                         'Education',
      'students' =>                        'Students',
      'family' =>                          'Family',
      'donors' =>                          'Donors',
      'donation_recipients' =>             'Donation/Grant Recipients',    
      'services_transactions' =>           'Services/Transactions',
      'lobbying' =>                        'Lobbying',
      'friendships' =>                     'Friendships',
      'professional_relationships' =>      'Professional Relationships',
      'owners' =>                          'Owners',
      'holdings' =>                        'Holdings',
      'children' =>                        'Child Organizations',
      'parents' =>                         'Parent Organizations',
      'miscellaneous' =>                   'Miscellaneous'
    }

    content_tag(:div, headings[section], class: "subsection") if links_count > 0
  end

end
