# frozen_string_literal: true

# intended to be subclassed to wrap PaperTrail::Version objects
class VersionPresenter < SimpleDelegator
  
  include ActionView::Helpers::UrlHelper
  delegate :relationship_path, :entity_path, :list_path, to: "Rails.application.routes.url_helpers"

  IGNORE_FIELDS = Set.new(%w[id created_at updated_at link_count last_user_id delta])

  protected

  def str_time
    LsDate.pretty_print(created_at)
  end

  def user_link
    return 'System' if user.nil?
    link_to user.username, "/users/#{user.username}"
  end

  def create_event?
    event == 'create'
  end

  def update_event?
    event == 'update'
  end

  def delete_event?
    event == 'soft_delete' || event == 'destroy'
  end

  def object
    PaperTrail::Serializers::YAML.load(super) unless super().nil?
  end

  def object_changes
    PaperTrail::Serializers::YAML.load(super) unless super().nil?
  end

  # create events store information about the fields in 'object' column
  # update events use the' object_changes column
  def fetch_from_object_or_changeset(field)
    method = create_event? ? :object_changes : :object
    Array.wrap(send(method).fetch(field)).compact.first
  end

  def updated_fields
    @updated_fields ||= (object_changes.keys.to_set - IGNORE_FIELDS).to_a
  end

  def model
    @model ||= item_type.constantize.unscoped.find(item_id)
  end
end
