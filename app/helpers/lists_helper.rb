# frozen_string_literal: true

module ListsHelper

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

  def list_tab_li(tab, selected, list)
    html_class = tab == selected ? 'tab active' : 'tab'
    content_tag(:li, class: html_class) do
      link_to tab.to_s.capitalize, link_tab_url(tab, list)
    end
  end

  # symbol, list -> <ul>
  def list_tab_menu(selected, list)
    content_tag(:ul) do
      list_tab_menu_options(list).reduce(''.html_safe) do |memo, tab|
        memo + list_tab_li(tab, selected, list)
      end
    end
  end

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

  def list_link(list, name=nil)
    name ||= list.name
    link_to(name, members_list_path(list))
  end

  def nil_string(maybe_nil)
    if maybe_nil.nil?
      return "nil"
    else
      return maybe_nil
    end
  end

  def list_page_title
    return 'Featured Lists' if featured_lists
    return "Lists featuring #{@entity.name}" if @entity
    return 'Your lists' if controller.controller_name == 'home'

    'All Lists'
  end

  def featured_lists
    @featured_lists ||= ActiveModel::Type::Boolean.new.cast(params[:featured])
  end
end
