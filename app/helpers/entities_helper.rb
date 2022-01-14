# frozen_string_literal: true

module EntitiesHelper
  # So we can use the concretize URL helpers outside of contexts that have access to routing
  include Rails.application.routes.url_helpers
  delegate :default_url_options, to: 'Rails.application'

  # Define "concretize" URL helpers for every entity controller route.
  # These return a version of that route which returns the entity's
  # primary_ext in the path instead of the generic /entities/....
  #
  # ==== Examples
  #
  # Assuming entity 1234-Malwart has the primary_ext "Org":
  #
  # * supplement entity_path(entity) with concretize_entity_path(entity), which returns
  # /org/1234-Malwart instead of /entities/1234-Malwart
  #
  # * supplement datatable_entity_url(entity, format: :json) with
  # concretize_datatable_entity_url(entity, format: :json), which returns
  # /org/1234-Malwart/datatable.json instead of /entities/1234-Malwart/datatable.json
  #
  Rails.application.routes.routes
    .select { |r| r.defaults[:controller] =~ /entities/ || r.defaults[:action] == 'entity' }
    .each do |route|
    next unless route.name&.match?(/entities|entity/)

    suffixes = %w[path url]
    suffixes.each do |suffix|
      define_method("concretize_#{route.name}_#{suffix}") do |entity, **args|
        send(concrete_url_helper_name(route, entity, suffix), entity, **args)
      end
    end
  end

  def concrete_url_helper_name(route, entity, suffix)
    "#{route.name.gsub(/entity|entities/, entity.primary_ext.downcase)}_#{suffix}"
  end

  def entity_primary_ext_display(entity)
    if entity.org?
      'organization'
    else
      'person'
    end
  end

  def active_tab?(tab_name, active_tab)
    if active_tab.casecmp(tab_name).zero?
      'active'
    else
      'inactive'
    end
  end

  # Relationships display

  def section_heading(links)
    tag.div(links.heading, class: "subsection") if links.count.positive?
  end

  # input: <Entity>, <LinksGroup>
  def link_to_all(entity, links)
    if links.count > 10
      tag.div(class: 'section_meta') do
        tag.span("Showing 1-10 of #{links.count} :: ") +
          link_to('see all', concretize_entity_url(entity, :relationships => links.keyword))
      end
    end
  end

  def section_order(entity)
    section_order_person = [
      'business_positions',
      'government_positions',
      'in_the_office_positions',
      'other_positions',
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
      'staff',
      'owners',
      'other_positions',
      'parents',
      'children',
      'holdings',
      'members',
      'memberships',
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

  def type_select_boxes_person(entity)
    checkboxes(checked_ids: entity.extension_records.map(&:definition_id),
               definitions: ExtensionDefinition.person_types,
               per_row: 5)
  end

  def org_boxes_tier2(entity)
    checkboxes(checked_ids: entity.extension_records.map(&:definition_id),
               definitions: ExtensionDefinition.org_types_tier2.to_a,
               per_row: 3)
  end

  def org_boxes_tier3(entity)
    checkboxes(checked_ids: entity.extension_records.map(&:definition_id),
               definitions: ExtensionDefinition.org_types_tier3.to_a,
               per_row: 6)
  end

  # [int], [ExtensionDefinition], int
  def checkboxes(checked_ids:, definitions:, per_row: 5)
    definitions.each_slice(per_row).collect do |group|
      tag.div(class: 'col-sm-4') do
        group.map do |ed|
          tag.div(class: 'entity-extension-checkbox-wrapper') do
            checkbox_class = checked_ids.include?(ed.id) ? 'bi bi-check-square' : 'bi bi-square'
            tag.i(class: checkbox_class,
                  data: {
                    action: 'click->entity-edit#checkType',
                    definition_id: ed.id
                  }
                 ) + tag.span(ed.display_name)
          end
        end.join.html_safe
      end
    end.join.html_safe
  end

  # <FormBuilder Thingy> -> [options for select]
  def gender_select_options(person_form)
    person = person_form.instance_variable_get("@object")
    selected = person.gender_id.nil? ? 'nil' : person.gender_id
    options_for_select([['', ''], ['Female', 1], ['Male', 2], ['Other', 3]], selected)
  end

  def profile_image(entity)
    image_src = if entity.has_featured_image
                  entity.featured_image_path
                elsif entity.person?
                  asset_path('system/anon.png')
                else
                  asset_path('system/anons.png')
                end

    image_tag image_src, alt: entity.name, class: 'entity-profile-image'
  end

  # input: string, [string], [block]
  def sidebar_header(title_text, subtitle: nil, addon: '')
    content = tag.div(class: 'sidebar-title-container thin-grey-bottom-border') do
      tag.span(title_text, class: 'lead sidebar-title-text') + addon
    end
    if subtitle.nil?
      content
    else
      content + tag.div(subtitle, class: 'section-pointer')
    end
  end

  def sidebar_similar_entities(similar_entities)
    similar_entities
      .collect { |e| link_to(e.name, e.legacy_url) }
      .collect { |link| content_tag(:li, link) }
      .reduce(&:+)
  end

  def entity_links(entities)
    safe_join(entities.map { |e| link_to(e.name, concretize_entity_path(e)) }, ', ')
  end

  def political_tab_col_left
    content_tag(:div, class: 'col-md-8 col-sm-8 nopadding') { yield }
  end

  def political_tab_col_right
    content_tag(:div, class: 'col-md-4 col-sm-4 double-left-padding') { yield }
  end

  def entity_tabs(entity, active_tab)
    tab_contents = [
      { text: 'Relationships',  path: concretize_entity_path(entity) },
      { text: 'Interlocks',     path: concretize_tab_entity_path(entity, tab: :interlocks) },
      { text: 'Giving',         path: concretize_tab_entity_path(entity, tab: :giving) },
      # { text: 'Political',      path: concretize_political_entity_path(entity) },
      { text: 'Data',           path: concretize_datatable_entity_path(entity) }
    ]

    tag.div(class: 'button-tabs') do
      tab_contents.map do |tab|
        tag.span(class: active_tab?(tab[:text], active_tab)) do
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

  # Creates html for edit entity form:
  # <div class="<%= input_div_wrapper_class %>">
  #   <div class="<%= left_col_class %>">
  #     LABEL
  #   </div>
  #   <div class="<%= right_col_class %>">
  #     INPUT
  #   </div>
  # </div>
  def edit_entity_form_section(label, input)
    input_div_wrapper_class = 'row mb-3'
    left_col_class = 'col-2'
    right_col_class = 'col-6'

    tag.div(class: input_div_wrapper_class) do
      tag.div(label, class: left_col_class) + tag.div(input, class: right_col_class)
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

  def profile_page_sidebar(container_id, header_title, **kwargs)
    tag.div(id: container_id, class: 'row') do
      tag.div(sidebar_header(header_title, **kwargs), class: 'col-sm-12') +
        tag.div(class: 'col-sm-12') { yield }
    end
  end

  def show_cmp_data_partner?(entity)
    entity.in_cmp_strata? && user_signed_in?
  end
end
