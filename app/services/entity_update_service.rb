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
        if entity_params.need_to_create_new_reference?
          entity.add_reference(entity_params.document_attributes)
        end

        entity.update_extension_records(entity_params.extension_def_ids)

        if entity_params.submitted_with_regions? or entity_params.submitted_with_countries?
          current_regions = entity.region_numbers.to_set
          proposed_regions = entity_params.region_numbers&.to_set || Set[]
          entity.add_regions(*proposed_regions.difference(current_regions))
          entity.remove_regions(*current_regions.difference(proposed_regions))

          current_countries = entity.country_codes.to_set
          proposed_countries = entity_params.country_codes&.to_set || Set[]
          entity.add_countries(*proposed_countries.difference(current_countries))
          entity.remove_countries(*current_countries.difference(proposed_countries))
        end

        entity.save!
      end
    end

    return entity
  end
end
