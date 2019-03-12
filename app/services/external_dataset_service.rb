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

    def self.match(entity:, external_dataset:)
      entity = Entity.entity_for(entity)
      extension = entity.org? ? 'Business' : 'BusinessPerson'
      crd_number = external_dataset.row_data['OwnerID']

      ApplicationRecord.transaction do
        if crd_number?(crd_number)
          if entity.has_extension?(extension)
            entity.merge_extension extension, crd_number: crd_number.to_i
          else
            entity.add_extension extension, crd_number: crd_number.to_i
          end
        else
          entity.add_extension extension
        end
        external_dataset.update! entity_id: entity.id
      end
    end

    def self.unmatch
    end

    def self.crd_number?(crd)
      return false if crd.blank? || crd.include?('-')

      /\A\d+\z/.match?(crd)
    end
  end

  class OtherDataset < SimpleDelegator
    # other datasets
  end
end
