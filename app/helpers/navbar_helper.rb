# frozen_string_literal: true

module NavbarHelper
  def navbar_item(dropdown: true)
    class_name = dropdown ? 'nav-item dropdown' : 'nav-item'
    tag.li(class: class_name) { yield }
  end

  def navbar_dropdown_item(text, href)
    link_to text, href, class: 'dropdown-item'
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

  # links = [ [link_name, link_url] ]
  def navbar_dropdown(links)
    tag.div(class: 'dropdown-menu') do
      links.map do |link|
        if link == :divider
          tag.div nil, class: 'dropdown-divider'
        else
          navbar_dropdown_item(*link)
        end
      end.reduce(:+)
    end
  end
end
