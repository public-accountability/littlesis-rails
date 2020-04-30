# frozen_string_literal: true

# This creates (or updates) External Entities and External Relationships

module IapdProcessor
  module_function

  def run
    ExternalData.iapd_advisors.find_each do |iapd_advisor|
      process_one iapd_advisor
    end
  end

  def process_one(iapd_advisor)
    external_entity = ExternalEntity
                        .find_or_create_by!(dataset: 'iapd_advisors', external_data: iapd_advisor)
    # Iapd Advisors are linked via crd numbers that are stored as the dataset_id.
    # If the entity is not matched, this will automatically match the entity when there is
    # already a crd number associated with an existing entity
    unless external_entity.matched?
      crd_number = iapd_advisor.dataset_id
      external_link = ExternalLink.crd.find_by(link_id: crd_number)

      if external_link.present?
        external_entity.update!(entity_id: external_link.entity_id)
      end
    end
  end
end