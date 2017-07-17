module ToolsHelper
  # Creates <select> html with relationship category options
  #--------------
  # Adds two 'unofficial' Relationship category options: 50 & 51
  # 50 represents "Donations Received" where the selected entity is entity2
  # 51 represents "Donations Given" where the selected entity is entity1
  def relationship_select_builder(cat)
    content_tag(:select, class: 'selectpicker', id: 'relationship-cat-select') do
      Relationship.categories_for(cat).reject { |c| c == 5 }.map do |c|
        content_tag(:option, Relationship.all_categories[c], value: c)
      end.unshift(content_tag(:option, ''))
        .push(content_tag(:option, 'Donations Received', value: 50))
        .push(content_tag(:option, 'Donations Given', value: 51))
        .reduce(:+)
    end
  end
end
