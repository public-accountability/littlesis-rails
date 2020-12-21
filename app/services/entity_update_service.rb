# frozen_string_literal: true

module EntityUpdateService
  def self.run(entity:, params:, current_user:)
    entity_params = Entity::Parameters.new(params)
    entity.assign_attributes(entity_params.update_entity)
    entity.last_user_id = current_user.id

    if entity_params.need_to_create_new_reference?
      entity.validate_reference(entity_params.document_attributes)
    end

    if entity.valid?
      ApplicationRecord.transaction do
        entity.update_extension_records(entity_params.extension_def_ids)
        entity.add_reference(entity_params.document_attributes) if entity_params.need_to_create_new_reference?
        entity.save!
      end
    end

    return entity
  end
end
