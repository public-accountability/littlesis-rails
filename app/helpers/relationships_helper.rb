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
    if rel.title.nil?
      return ""
    else
      return " (" + rel.title + ") "
    end
  end

  def references_select(references)
    content_tag(:select, class: 'selectpicker', id: 'references-select') do
      references.map do |r|
        content_tag(:option, r.name, value: r.id)
      end.unshift(content_tag(:option, '')).reduce(:+)
    end
  end

  def d1_is_title
    [1, 3, 5, 10].include? @relationship.category_id
  end

  def form_tag(label, field)
    content_tag(:div, class: 'form-group') do
      label + content_tag(:div, class: 'col-sm-6') { field }
    end
  end
end
