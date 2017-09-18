module TagsHelper
  def display_tags(tags)
    content_tag(:div, id: 'tags-container') do
      content_tag(:ul, id: 'tags-list') do
        tags.reduce(''.html_safe) do |html, tag|
          html + content_tag(:li) do
            link_to(tag.name, tag, class: 'tag')
          end
        end
      end
    end
  end

  def tags_controls
    content_tag(:span, id: 'tags-controls') do
      content_tag(:span, nil, id: 'tags-edit-button', class: 'tags-edit-glyph')
    end
  end

  def tagable_list_sort_info(tagable, tag)
    return "#{tagable.related_tagged_entities} #{tag.name} relationships" if tagable.is_a? Entity
    "edited #{time_ago_in_words(tagable.updated_at)} ago"
  end
end
