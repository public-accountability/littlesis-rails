module RelationshipsHelper
  def rel_link(rel, name=nil)
    name ||= rel.name
    link_to name, rel.legacy_url
  end

  def relationship_date(rel)
    start = rel.start_date
    endt = rel.end_date
    current = rel.is_current

    # if no start or end date, but is_current is false, we say so
    return 'past' if endt.nil? and current == '0'

    # if start == end, return single date
    return display_date(endt, true) if endt and start == endt

    s = display_date(start, true)
    e = display_date(endt, true)
    span = ""

    if s
      span = s + " &rarr; "
      span += e if e
    elsif e
      span = "? &rarr; " + e
    end
  
    span
  end

  def display_date(str, abbreviate = false)
    return nil if str.nil?
    year, month, day = str.split("-")
    abbreviate = false if year.to_i < 1930
    return Time.parse(str).strftime("%b %-d '%y") if year.to_i > 0 and month.to_i > 0 and day.to_i > 0
    if year.to_i > 0 and month.to_i > 0
      return Time.parse([year, month, 1].join("-")).strftime("%b '%y")
    end
    return (abbreviate ? "'" + year[2..4] : year) if year.to_i > 0
    ""
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
  
  # input: <FormBuilder thingy>, symbol
  def radio_buttons_producer(form, column)
    form.radio_button(column, 'true') +
    form.label(column, 'Yes') +
    form.radio_button(column, 'false') +
    form.label(column, 'No') +
    form.radio_button(column, '') +
    form.label(column, 'Unknown')
  end

  # family, transaction, social, professional, hiearchy, generic
  def requires_description_fields
    [4, 6, 8, 9, 11, 12].include? @relationship.category_id
  end

  def description_fields(f)
    return nil unless requires_description_fields
    content_tag(:div, id: 'description-fields') do
      [entity_link(@relationship.entity),
       ' is ',
       f.text_field(:description1),
       ' of ',
       entity_link(@relationship.related),
       tag(:br),
       reverse_link_if,
       entity_link(@relationship.related),
       ' is ',
       f.text_field(:description2),
       ' of ',
       entity_link(@relationship.entity)].reduce(:+)
    end
  end

  def reverse_link_if
    # Hierarchy relationships are the only reversible relationship
    # that have both description_fields and description fields display.
    # This prevents the switch icon from appearing twice
    return nil unless @relationship.is_reversible? && !@relationship.is_hierarchy?
    content_tag(:div, class: 'm-left-1em top-1em') { reverse_link + tag(:br) }
  end

  def reverse_link
    link_to reverse_direction_relationship_path(@relationship), method: :post do
      content_tag(:span, nil, {'class' => 'glyphicon glyphicon-retweet icon-link hvr-pop', 'aria-hidden' =>  true, 'title' => 'switch'}) +
        content_tag(:span, 'switch', style: 'padding-left: 5px')
    end
  end

  def relationship_form_tag(label, field, html_class = 'col-sm-10')
    content_tag(:div, class: 'form-group') do
      label + content_tag(:div, class: html_class) { field }
    end
  end
end
