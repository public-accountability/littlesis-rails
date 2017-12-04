module EntitiesHelper
  
  def entity_hash_link(entity, name=nil, action=nil)
    name ||= entity['name']
    link_to name, Entity.legacy_url(entity['primary_ext'], entity['id'], name, action)
  end

  def tiny_entity_image(entity)
    content_tag('div', nil, class: "entity_tiny_image", style: "background-image: url('#{image_path(entity.featured_image_url('small'))}');")
  end

  def active_tab?(tab_name, active_tab)
    if active_tab.downcase == tab_name.downcase
      return 'active'
    else
      return 'inactive'
    end
  end

  # Relationships display

  def section_heading(links)
    content_tag(:div, links.heading, class: "subsection") if links.count > 0
  end

  # input: <Entity>, <LinksGroup>
  def link_to_all(entity, links)
    content_tag :div, class: 'section_meta' do
      content_tag(:span, "Showing 1-10 of #{links.count} :: ") + link_to('see all', entity_url(entity, :relationships => links.keyword))
    end if links.count > 10
  end

  def section_order(entity)
    section_order_person = [
      'business_positions',
      'government_positions',
      'in_the_office_positions',
      'other_positions_and_memberships',
      'memberships',
      'schools',
      'holdings',
      'services_transactions',
      'family',
      'professional_relationships',
      'friendships',
      'donors',
      'donation_recipients',
      'staff',
      #  'political_fundraising_committees',
      'lobbies',
      'lobbied_by',
      'miscellaneous'
    ]

    section_order_org = [
      'parents',
      'children',
      'holdings',
      'other_positions_and_memberships',
      'owners',
      'members',
      'memberships',
      'staff',
      'donation_recipients',
      'donors',
      'services_transactions',
      'students',
      'lobbies',
      'lobbied_by',
      'miscellaneous'
    ]

    entity.person? ? section_order_person : section_order_org
  end

  def extra_links_count(links)
    return '' if links.count <= 1
    "[+#{links.count - 1}]"
  end

  def type_select_boxes_person(entity = @entity)
    boxes_to_html(checkboxes(entity, ExtensionDefinition.person_types))
  end

  def org_boxes_tier2(entity = @entity)
    boxes_to_html(checkboxes(entity, ExtensionDefinition.org_types_tier2), 4)
  end

  def org_boxes_tier3(entity = @entity)
    boxes_to_html(checkboxes(entity, ExtensionDefinition.org_types_tier3), 6)
  end

  # [ content_tag ] => html
  def boxes_to_html(boxes, slice = 5)
    boxes.each_slice(slice).reduce('') do |x, box_group|
      x + content_tag(:div, box_group.reduce(:+), class: 'col-sm-4')
    end.html_safe
  end

  def checkboxes(entity, definitions)
    checked_def_ids = entity.extension_records.map(&:definition_id)
    definitions.collect do |ed|
      is_checked = checked_def_ids.include?(ed.id)
      content_tag(:span, class: 'entity-type-checkbox-wrapper') do
        glyph_checkbox(is_checked, ed.id) + content_tag(:span, " #{ed.display_name}", class: 'entity-type-name') + tag(:br)
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

  # input: string, [string], [block]
  def sidebar_header(title_text, subtitle: nil, addon: '')
    content = content_tag(:div, class: 'sidebar-title-container thin-grey-bottom-border') do
      content_tag(:span, title_text, class: 'lead sidebar-title-text') + addon
    end
    return content if subtitle.nil?
    content + content_tag(:div, subtitle, class: 'section-pointer')
  end

  def sidebar_industry_links(os_categories)
    os_categories.to_a
      .delete_if { |cat| cat.ignore_me_in_view }
      .collect {  |cat| link_to(cat.category_name, cat.legacy_path) } 
      .join(', ')
  end

  # To eager load list and list_entities: Entity.includes(list_entities: [:lists])
  def sidebar_lists(list_entities)
    list_entities.collect do |list_entity|
      if show_list(list_entity)
        content_tag(:li, sidebar_list_link(list_entity), class: 'sidebar-list')
      else
        "".html_safe
      end
    end.reduce(:+)
  end

  def sidebar_list_link(list_entity)
    link = link_to list_entity.list.name , list_path(list_entity.list), class: 'link-blue'
    link += content_tag(:samp, "[\##{list_entity.rank}]") if list_entity.list.is_ranked? && list_entity.rank.present?
    link
  end

  def sidebar_similar_entities(similar_entities)
    similar_entities
      .collect { |e| link_to(e.name, e.legacy_url) }
      .collect { |link| content_tag(:li, link) }
      .reduce(&:+)
  end

  def get_form_id(f)
    f.instance_variable_get('@options')[:html][:id]
  end

  # <User> -> Boolean
  def show_add_bulk_button(user)
    return true if user.admin? || user.bulker?
    return true if user.created_at < 2.weeks.ago && user.sign_in_count > 2
    false
  end

  def entity_links(entities)
    safe_join(entities.map { |e| link_to(e.name, e) }, ', ')
  end


  # Filters refereces to uniq url/name
  def filter_and_limit_references(refs)
    refs.uniq { |ref| "#{ref.name}#{ref.source}" }.take(10)
  end

  # skip deleted lists, private lists (unless current_user has access), and skip lists that are networks
  def show_list(list_entity)
    list = list_entity.list
    return false if list.nil? || list.is_network?
    list.user_can_access?(current_user)
  end

  def political_tab_col_left
    content_tag(:div, class: 'col-md-8 col-sm-8 nopadding') { yield }
  end

  def political_tab_col_right
    content_tag(:div, class: 'col-md-4 col-sm-4 double-left-padding') { yield }
  end

  def entity_tabs(entity, active_tab)
    tab_contents = [
      { text: 'Relationships',  path: entity_path(entity) },
      { text: 'Interlocks',     path: interlocks_entity_path(entity) },
      { text: 'Giving',         path: giving_entity_path(entity) },
      { text: 'Political',      path: political_entity_path(entity) },
      { text: 'Data',           path: datatable_entity_path(entity) }
    ]
    content_tag(:div, class: 'button-tabs') do
      tab_contents.map do |tab|
        content_tag(:span, class: active_tab?(tab[:text], active_tab)) do
          link_to tab[:text], tab[:path]
        end
      end.reduce(:+)
    end
  end

  def entity_connections_header(connection_type, e)
    title, subtitle = connections_title_and_subtitle(connection_type, e)
    content_tag(:div, id: "entity-connections-header") do
      content_tag(:div, title, id: "entity-connections-title") +
        content_tag(:div, subtitle, id: "entity-connections-subtitle")
    end
  end

  def entity_connections_table_headers(connection_type, e)
    content_tag(:thead) do
      content_tag(:tr) do
        header_attributes = connections_table_header_attributes(connection_type, e.primary_ext)
        header_attributes.map { |x| content_tag(:th, x[:text], id: x[:id]) }.reduce(:+)
      end
    end
  end

  private

  def connections_title_and_subtitle(connection_type, e)
    case [connection_type, e.primary_ext]
    when [:interlocks, "Person"]
      ["People in Common Orgs",
       "People with positions in the same orgs as #{e.name}"]
    when [:interlocks, "Org"]
      ["Orgs with Common People",
       "Leadership and staff of #{e.name} also have positions in these orgs"]
    when [:giving, "Person"]
      ["Donors to Common Recipients",
       "Recipients of donations from #{e.name} also received donations from these orgs and people"]
    when [:giving, "Org"]
      ["People Have Given To",
       "People with positions in #{e.name} have made donations to"]
    end
  end

  def connections_table_header_attributes(connection_type, primary_ext)
    case [connection_type, primary_ext]
    when [:interlocks, "Person"]
      [{ text: 'Person',            id: 'connected-entity-header'  },
       { text: 'Common Orgs',       id: 'connecting-entity-header' }]
    when [:interlocks, 'Org']
      [{ text: 'Org',               id: 'connected-entity-header'  },
       { text: 'Common People',     id: 'connecting-entity-header' }]
    when [:giving, 'Person']
      [{ text: 'Donor',             id: 'connected-entity-header'  },
       { text: 'Common Recipients', id: 'connecting-entity-header' }]
    when [:giving, 'Org']
      [{ text: 'Recipient',         id: 'connected-entity-header'  },
       { text: 'Total',             id: 'connection-stat-header'   },
       { text: 'Donors',            id: 'connecting-entity-header' }]
    end
  end

  def connections_table_header_text(connection_type, primary_ext)
    case [connection_type, primary_ext]
    when [:interlocks, "Person"]
      ["Person", "Common Orgs"]
    when [:interlocks, "Org"]
      ["Org", "Common People"]
    when [:giving, "Person"]
      ["Donor", "Common Recipients"]
    when [:giving, "Org"]
      ["Recipient", "Donors"]
    end
  end
end
