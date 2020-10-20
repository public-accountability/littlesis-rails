# frozen_string_literal: true

class EntityVersionPresenter < VersionPresenter
  def render
    "#{user_link} #{action} at #{time}"
  end

  def action
    case item_type
    when 'Entity'
      return 'created the entity' if create_event?
      return updated_fields_text if update_event?
      return 'deleted the entity' if delete_event?
    when 'ExtensionRecord'
      return "added extension #{extension_name}" if create_event?
      return "removed extension #{extension_name}" if delete_event?
    when 'Tagging'
      return "added tag #{tag_name}" if create_event?
      return "removed tag #{tag_name}" if delete_event?
    when 'Relationship'
      return "added a new #{relationship_link} with #{entity_link}" if create_event?
      return "updated #{relationship_link} with #{entity_link}" if update_event?
      return "removed a #{relationship_link} with #{entity_link}" if delete_event?
    when 'Alias'
      return "added a alias #{alias_name}" if create_event?
      return "renamed the alias #{alias_name}" if delete_event?
    when 'ListEntity'
      return "added this entity to the list #{list_name}" if create_event?
      return "removed this entity from the list #{list_name}" if delete_event?
    when 'ExternalLink'
      return "added a #{external_link_name} link" if create_event?
      return "updated a #{external_link_name} link" if update_event?
      return "removed a #{external_link_name} link" if delete_event?
    when *Entity.all_extension_names_with_fields
      return updated_fields_text if update_event?
    else
      raise Exceptions::ThatsWeirdError, "Trying to process Entity Version with type: #{item_type}"
    end
  end

  private

  def time
    "<em>#{str_time}</em>"
  end

  def entity_link
    related_entity = model.entity_related_to(entity)
    if related_entity.is_deleted
      related_entity.name
    else
      link_to related_entity.name, concretize_entity_path(related_entity)
    end
  end

  def relationship_link
    model.is_deleted ? "relationship" : link_to("relationship", relationship_path(model))
  end

  def alias_name
    fetch_from_object_or_changeset('name')
  end

  def tag_name
    tag_id = fetch_from_object_or_changeset('tag_id')
    Tag.lookup.fetch(tag_id).name
  end

  def list_name
    return '?' if other_id.blank?
    list = List.unscoped.find(other_id)
    return list.name if list.is_deleted
    link_to list.name, list_path(list)
  end

  def extension_name
    definition_id = fetch_from_object_or_changeset('definition_id')
    ExtensionDefinition.display_names.fetch(definition_id)
  end

  def updated_fields_text
    "updated #{'field'.pluralize(updated_fields.length)} #{updated_fields.join(',')}"
  end

  def external_link_name
    ExternalLink
      .info(fetch_from_object_or_changeset('link_type'))
      .first
  end
end
