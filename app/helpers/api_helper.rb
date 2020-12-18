# frozen_string_literal: true

module ApiHelper
  def attribute_line(attr, details)
    tag.li (tag.mark(attr) + ": #{details}")
  end

  def api_title_route(title, route)
    tag.h3(title) + tag.h3(tag.code(route))
  end

  def api_column(&block)
    tag.div(class: 'col-md-12', &block)
  end
end
