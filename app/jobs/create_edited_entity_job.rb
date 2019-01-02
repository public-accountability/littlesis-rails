# frozen_string_literal: true

class CreateEditedEntityJob < ApplicationJob
  queue_as :default

  def perform(version)
    TypeCheck.check version, PaperTrail::Version
    return if version.entity1_id.nil?

    base_attributes = { user_id: version.whodunnit&.to_i,
                        version_id: version.id,
                        created_at: version.created_at }

    EditedEntity.create! base_attributes.merge(entity_id: version.entity1_id)

    if version.entity2_id.present? && (version.entity2_id != version.entity1_id)
      EditedEntity.create! base_attributes.merge(entity_id: version.entity2_id)
    end
  end
end
