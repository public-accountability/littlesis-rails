# frozen_string_literal: true

module ExternalDatasetService
  class InvalidMatchError < Exceptions::LittleSisError; end

  # For IAPD it:
  #   * adds business or business person extension
  #   * adds crd number
  module Iapd
    def self.validate_match!(entity:, external_dataset:)
      entity = Entity.entity_for(entity)
      extension = entity.org? ? :business : :business_person

      if entity.public_send(extension)&.crd_number&.present?
        msg = "Entity #{entity.id} already has a crd_number. Cannot match row#{external_dataset.id}"
        raise InvalidMatchError, msg
      end
    end

    def self.match(entity_or_entity_id)
    end

    def self.unmatch
    end
  end

  class OtherDataset < SimpleDelegator
    # other datasets
  end
end
