# frozen_string_literal: true

class PoliticalFundraising < ApplicationRecord
  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id },
                  versions: { class_name: 'ApplicationVersion' }

  belongs_to :entity, inverse_of: :political_fundraising
end
