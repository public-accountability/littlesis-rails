module ToolsHelper
  def select_builder(cat)
    content_tag(:select, class: 'selectpicker', id: 'relationship-cat-select') do
      Relationship.categories_for(cat).map do |c|
        content_tag(:option, Relationship.all_categories[c], value: c)
      end.unshift(content_tag(:option, '')).reduce(:+)
    end
  end
end
