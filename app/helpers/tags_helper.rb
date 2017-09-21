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
    return "#{tagable.num_related} #{tag.name} relationships" if tagable.is_a? Entity
    "edited #{time_ago_in_words(tagable.updated_at)} ago"
  end

  def tagable_link(tagable)
    link_to tagable.name, send("#{tagable.class.name.downcase}_path", tagable)
  end

  def tags_edits_format_time(edit_event)
    if edit_event['event'] == 'tag_added' || edit_event['tagable_class'] == 'List'
      "Edited #{time_ago_in_words(edit_event['event_timestamp'])} ago"
    else
      username = edit_event['tagable']&.last_user&.user&.username || 'System'
      "Edited #{time_ago_in_words(edit_event['event_timestamp'])} ago by #{username}"
    end
  end

  def tags_edits_format_action(edit_event)
    action_text = { 'tagable_updated' => 'updated', 'tag_added' => 'tagged' }
    "#{edit_event['tagable_class']} #{action_text[edit_event['event']]}"
  end
end
