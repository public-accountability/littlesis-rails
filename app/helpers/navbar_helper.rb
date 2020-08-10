# frozen_string_literal: true

module NavbarHelper
  def navbar_item(dropdown: true)
    class_name = dropdown ? 'nav-item dropdown' : 'nav-item'
    tag.li(class: class_name) { yield }
  end

  def navbar_dropdown_item(text, href)
    link_to text, href, class: 'dropdown-item'
  end

  def navbar_dropdown_divider
    tag.div nil, class: 'dropdown-divider'
  end

  def navbar_header_link(text, dropdown: true, href: '#')
    class_name = dropdown ? 'nav-link dropdown-toggle' : 'nav-link'
    options = { 'class' => class_name, 'href' => href, 'id' => "navbar-header-#{text}" }
    if dropdown
      options.merge!('role' => 'button',
                     'data-toggle' => 'dropdown',
                     'aria-haspopup' => 'true',
                     'aria-expanded' => 'false')
    end
    tag.a(text, **options)
  end

  def navbar_dropdown(items)
    tag.div(class: 'dropdown-menu') do
      items.map do |item_text, url|
        if url == 'divider'
          navbar_dropdown_divider
        else
          navbar_dropdown_item(item_text, url)
        end
      end.reduce(:+)
    end
  end
end
