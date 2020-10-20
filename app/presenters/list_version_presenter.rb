# frozen_string_literal: true

class ListVersionPresenter < VersionPresenter
  include EntitiesHelper

  def render
    "#{user_link} #{action} at <em>#{str_time}</em>"
  end

  private

  def action
    case item_type
    when 'List'
      return 'created the list' if create_event?
      return 'updated the list' if update_event?
      return 'deleted the list' if delete_event?
    when 'ListEntity'
      return "added #{entity_link} to the list" if create_event?
      return "removed #{entity_link} from the list" if delete_event?
    else
      raise Exceptions::ThatsWeirdError, "Trying to process ListVersion with type: #{item_type}"
    end
  end

  def entity_link
    entity = Entity.unscoped.find(entity1_id)
    if entity.is_deleted
      entity.name
    else
      link_to entity.name, concretize_entity_path(entity)
    end
  end
end
