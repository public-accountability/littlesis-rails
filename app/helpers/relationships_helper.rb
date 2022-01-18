# frozen_string_literal: true

module RelationshipsHelper
  def rel_link(rel, name = nil)
    name ||= rel.name
    link_to name, relationship_url(rel)
  end

  def title_in_parens(rel)
    if rel.description.nil?
      return ""
    else
      return " (" + rel.title + ") "
    end
  end

  def d1_is_title
    [1, 3, 10].include? @relationship.category_id
  end

  def d1_label_text(relationship)
    if relationship.is_ownership?
      'Description'
    elsif relationship.is_donation?
      'Type'
    else
      'Title'
    end
  end

  # family, transaction, social, professional, hiearchy, generic
  def requires_description_fields
    [4, 6, 8, 9, 11, 12].include? @relationship.category_id
  end

  def description_fields(f)
    return nil unless requires_description_fields
    content_tag(:div, id: 'description-fields') do
      [entity_link(@relationship.entity, html_id: 'df-forward-link-entity1'),
       ' is ',
       f.text_field(:description1, pattern: '(.{1}){0,100}'),
       ' of ',
       entity_link(@relationship.related, html_id: 'df-forward-link-entity2'),
       tag(:br),
       content_tag(:div, nil, class: 'description-fields-break'),
       reverse_link_if,
       entity_link(@relationship.related, html_id: 'df-backward-link-entity2'),
       ' is ',
       f.text_field(:description2, pattern: '(.{1}){0,100}'),
       ' of ',
       entity_link(@relationship.entity, html_id: 'df-backward-link-entity1')].reduce(:+)
    end
  end

  def reverse_link_if
    # Hierarchy relationships are the only reversible relationship
    # that have both description_fields and description fields display.
    # This prevents the switch icon from appearing twice
    return nil unless @relationship.reversible? && !@relationship.is_hierarchy?
    content_tag(:div, class: 'm-left-1em top-1em') { reverse_link + tag(:br) }
  end

  def reverse_link
    data = { "controller" => 'reverse-link',
             "reverse-link-url-value" => reverse_direction_relationship_path(@relationship) }

    tag.div(id: 'relationship-reverse-link', data: data) do
      tag.button(data: { action: "click->reverse-link#onClick" }, class: 'bg-transparent border-0') do
        tag.span('class' => 'bi bi-arrow-down-up icon-link hvr-pop') + tag.span('switch', style: 'padding-left: 5px')
      end
    end
  end

  def relationship_form_tag(label, field)
    label + content_tag(:div, field, class: 'form-input-wrapper')
  end

  # <Relationship> -> [ Struct ]
  # Struct fields: title (String), entity (Entity)
  def description_fields_titles_and_entites(relationship)
    titles = Relationship::DESCRIPTION_FIELDS_DISPLAY_NAMES[relationship.category_id]
    entities = [relationship.entity, relationship.related]
    titles_and_entities = titles.zip(entities)
    titles_and_entities.reverse! if relationship.is_hierarchy?
    titles_and_entities.map { |x| Struct.new(:title, :entity).new(*x) }
  end

  def options_for_currency_select
    move_elements_to_start_of_array([:usd, :gbp, :eur], sorted_currencies)
      .collect { |c| [c[:display], c[:iso]] }
  end

  private

  def sorted_currencies
    Money::Currency.table
      .map { |k, v| { iso: k, display: currency_display_name(v) } }
      .sort_by { |c| c[:iso] }
  end

  def currency_display_name(currency)
    "#{currency[:iso_code]} (#{currency[:name]})"
  end

  def move_elements_to_start_of_array(elements, array)
    elements.reverse_each do |e|
      array.insert(0, array.delete_at(array.index { |c| c[:iso] == e }))
    end
    array
  end
end
