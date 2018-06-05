# frozen_string_literal: true

class PublicCompany < ApplicationRecord
  include SingularTable

  has_paper_trail on: [:update],
                  meta: { entity1_id: :entity_id }

  belongs_to :entity, inverse_of: :public_company
  validates :ticker, length: { maximum: 10 }

  def create_or_update_external_link
    return if sec_cik.blank?
    ExternalLink
      .find_or_initialize_by(entity_id: entity_id, link_type: 'sec')
      .update!(link_id: sec_cik.to_s)
  end
end
