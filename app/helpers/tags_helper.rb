module TagsHelper
  def display_tags(tags)
    content_tag(:div, id: 'tags-container') do
      content_tag(:ul, id: 'tags-list') do
        tags.reduce(''.html_safe) do |html, tag|
          html + link_to(tag, class: 'tag') do
            content_tag(:li, tag.name)
          end
        end
      end
    end
  end

  def tags_controls
    if user_signed_in?
      content_tag(:span, id: 'tags-controls') do
        content_tag(:span, nil, id: 'tags-edit-button', class: 'tags-edit-glyph')
      end
    end
  end

  def tagable_list_sort_info(tagable, tag)
    # TODO(ag): move this to an instance method on Tagable?
    case tagable
    when Entity
      "#{tagable.relationship_count} #{tag.name} relationships"
    when List
      "#{tagable.entity_count} list members"
    when Relationship
      "edited #{time_ago_in_words(tagable.updated_at)} ago"
    end
  end

  def tagable_link(tagable)
    link_to tagable.name, send("#{tagable.class.name.downcase}_path", tagable)
  end

  def tags_edits_format_time(edit_event)
    "#{time_ago_in_words(edit_event['event_timestamp'])} ago"
  end

  def tags_edits_format_action(edit_event)
    action_text = { 'tagable_updated' => 'updated', 'tag_added' => 'tagged' }
    "#{edit_event['tagable_class']} #{action_text[edit_event['event']]}"
  end

  def tags_edits_format_editor(edit_event)
    e = edit_event['editor']
    return "System" if e.nil? || e.username == "system"
    link_to(e.username, "/users/#{e.username}")
  end
end
