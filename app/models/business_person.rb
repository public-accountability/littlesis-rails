# frozen_string_literal: true

class BusinessPerson < ApplicationRecord
  include SingularTable
  include ExternalLinkUpdater

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :business_person
end
