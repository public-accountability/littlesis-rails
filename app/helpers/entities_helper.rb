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
  
  def get_other_positions_and_memberships_heading(positions_count, other_positions_count, memberships_count)
    if other_positions_count == 0
      return 'Memberships'
    elsif memberships_count == 0
      if other_positions_count == positions_count
        return 'Positions'
      else
        return 'Other Positions'
      end
    elsif other_positions_count == positions_count
      return 'Positions & Memberships'
    else
      return 'Other Positions & Memberships'
    end
  end

  def display_relationship_section_heading(links_count, pos_count, other_pos_count, mem_count, section)
    headings = {
      'staff' =>                           'Office/Staff',
      'business_positions' =>              'Business Positions',
      'government_positions' =>            'Government Positions',
      'in_the_office_positions' =>         'In The Office Of',
      'other_positions_and_memberships' =>  get_other_positions_and_memberships_heading(pos_count, other_pos_count, mem_count),
      'schools' =>                         'Education',
      'students' =>                        'Students',
      'family' =>                          'Family',
      'donors' =>                          'Donors',
      'donation_recipients' =>             'Donation/Grant Recipients',    
      'services_transactions' =>           'Services/Transactions',
      'lobbying' =>                        'Lobbying',
      'friendships' =>                     'Friends',
      'professional_relationships' =>      'Professional Relationships',
      'owners' =>                          'Owners',
      'holdings' =>                        'Holdings',
      'children' =>                        'Child Organizations',
      'parents' =>                         'Parent Organizations',
      'miscellaneous' =>                   'Miscellaneous'
    }

    content_tag(:div, headings[section], class: "subsection") if links_count > 0
  end

  def get_section_order(entity)
    section_order_person = ['business_positions', 'government_positions', 'in_the_office_positions', 'other_positions_and_memberships', 'schools', 'holdings', 'services_transactions', 'family', 'professional_relationships', 'friendships', 'donation_recipients', 'staff']
    section_order_org = ['parents', 'children', 'other_positions_and_memberships', 'staff']

    entity.person? ? section_order_person : section_order_org
  end

  def group_relationships_by_entity(links)
    links.group_by { |l| l.entity2_id }.values
  end

  def order(links)
    return [] if links.empty?
    return links.sort { |a, b| b.related.links.count <=> a.related.links.count } if links[0].category_id == 4
    return links.sort { |a, b| b.relationship.amount <=> a.relationship.amount } if links[0].category_id == 5
    return links.sort { |a, b| LsDate.new(b.relationship.end_date) <=> LsDate.new(a.relationship.end_date) }
  end
  
  # <Entity> -> html
  def type_select_boxes(entity = @entity)
    number_per_group = entity.org? ? 9 : 5
    checkboxes(entity).each_slice(number_per_group).reduce('') do |x, box_group|
        x + content_tag(:div, box_group.reduce(:+), class: 'col-sm-4')
    end.html_safe
  end

  # <Entity> -> [ content_tag ]
  def checkboxes(entity)
    checked_def_ids = entity.extension_records.map(&:definition_id)
    ExtensionDefinition.send("#{entity.primary_ext.downcase}_types").collect do |ed|
      is_checked = checked_def_ids.include?(ed.id)
      content_tag(:span, class: 'entity-type-checkbox-wrapper') do 
        glyph_checkbox(is_checked, ed.id) + content_tag(:span, " #{ed.display_name}", class: 'entity-type-name')+ tag(:br)
      end
    end
  end

  # boolean, [] -> content_tag
  def glyph_checkbox(checked, def_id)
    glyphicon_class = ['glyphicon']
    glyphicon_class.append(if checked then 'glyphicon-check' else 'glyphicon-unchecked' end)
    content_tag(:span, nil, class: glyphicon_class, aria_hidden: 'true', data: { definition_id: def_id })
  end

  # <FormBuilder Thingy> -> [options for select]
  def gender_select_options(person_form)
    person = person_form.instance_variable_get("@object")
    selected = person.gender_id.nil? ? 'nil' : person.gender_id
    options_for_select([['', ''], ['Female', 1], ['Male', 2], ['Other', 3]], selected)
  end

  def profile_image
    image_tag(@entity.featured_image_url, alt: @entity.name, class: 'img-rounded')
  end

  def sidebar_title(title)
    content_tag(:div, class: 'sidebar-title-container thin-grey-bottom-border') do
      content_tag(:span, title, class: 'lead sidebar-title-text') 
    end
  end

  def sidebar_reference_count(count)
    content_tag(:span, "Number of references: ") + content_tag(:em, count.to_s)
  end

  # input: Array or <ActiveRecord_relation>
  def sidebar_references(references)
    content_tag(:ul, class: 'list-unstyled') do
      references.collect { |r| sidebar_reference(r) }.reduce(&:+)
    end
  end

  def sidebar_reference(reference)
    link_to(
      content_tag(:li, reference.name.truncate(33)),
      reference.source,
      target: "_blank"
    )
  end
end
