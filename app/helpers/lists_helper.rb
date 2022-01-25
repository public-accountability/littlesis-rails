# frozen_string_literal: true

module ListsHelper
  def list_column_icon(column)
    classes = ['bi', 'list-sort-icon', 'rounded', 'p-1', 'bi-filter']
    current_ordered_column = params[:order_column].to_sym
    current_ordered_direction = params[:order_direction].to_sym

    if column == current_ordered_column
      case current_ordered_direction
      when :desc
        classes[-1] = 'bi-sort-down'
      when :asc
        classes[-1] = 'bi-sort-up'
      end
    end

    data = { 'action' => 'click->lists-search#setDirection', 'column' => column }
    tag.i(class: classes.join(' '), data: data)
  end

  # symbol, list -> <ul>
  def list_tab_menu(selected, list)
    content_tag(:ul) do
      list_tab_menu_options(list).reduce(''.html_safe) do |memo, tab|
        memo + list_tab_li(tab, selected, list)
      end
    end
  end

  def list_link(list)
    link_to(list.name, members_list_path(list), title: (list.short_description ? list.short_description : list.description))
  end

  def nil_string(maybe_nil)
    if maybe_nil.nil?
      return "nil"
    else
      return maybe_nil
    end
  end

  private

  # <List> -> [Array of symbols]
  def list_tab_menu_options(list)
    tabs = [:members]

    if list.entities.people.count.positive?
      tabs.concat [:interlocks, :giving]
      tabs << :funding if list.entities.people.count < 500
    end

    tabs << :sources
    tabs << :edits if user_signed_in?
    tabs
  end

  def list_tab_li(tab, selected, list)
    html_class = tab == selected ? 'tab active' : 'tab'
    content_tag(:li, class: html_class) do
      link_to tab.to_s.capitalize, link_tab_url(tab, list)
    end
  end

  def link_tab_url(tab, list)
    case tab
    when :members
      members_list_path(list)
    when :interlocks
      list_interlocks_path(list)
    when :giving
      list_interlocks_tab_path(list, tab)
    when :funding
      list_interlocks_tab_path(list, tab)
    when :sources
      references_list_path(list)
    when :edits
      modifications_list_path(list)
    else
      raise ArgumentError, "Unknown tab: #{tab}"
    end
  end
end
