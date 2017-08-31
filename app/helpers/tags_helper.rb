module TagsHelper
  def display_tags(tags)
    content_tag(:div, id: 'tags-container') do
      content_tag(:ul, id: 'tags-list') do
        tags.reduce(''.html_safe) do |html, tag|
          html + content_tag(:li, tag[:name], class: 'tag')
        end
      end
    end
  end

  def tags_controls
    content_tag(:span, id: 'tags-controls') do
      content_tag(:span, nil, id: 'tags-edit-button', class: 'tags-edit-glyph')
    end
  end
end
