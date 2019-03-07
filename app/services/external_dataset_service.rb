# frozen_string_literal: true

module ExternalDatasetService
  class InvalidMatchError < Exceptions::LittleSisError; end
  
  # For IAPD it:
  #   * adds business or business person extension
  #   * adds crd number
  class Iapd < SimpleDelegator
    def validate_match!(entity_or_entity_id)
      entity = Entity.entity_for(entity_or_entity_id)
      extension = entity.org? ? :business : :business_person

      if entity.public_send(extension)&.crd_number&.present?
        raise InvalidMatchError, "Entity #{entity.id} already has a crd_number. Cannot match row#{id}."
      end
    end

    def match(entity_or_entity_id)
    end

    def unmatch
    end
  end

  class OtherDataset < SimpleDelegator
    # other datasets
  end
end
