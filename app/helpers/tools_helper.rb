module ToolsHelper
  def select_builder(cat)
    content_tag(:select) do
      Relationship.categories_for(cat).map do |c|
        content_tag(:option, Relationship.all_categories[c], value: c)
      end.reduce(:+)
    end
  end
end
