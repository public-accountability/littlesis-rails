# frozen_string_literal: true

# This creates (or updates) External Entities and External Relationships

module IapdProcessor
  module_function

  def run
    ExternalData.iapd_advisors.find_each do |iapd_advisor|
      process_advisor iapd_advisor
    end

    ExternalData.iapd_owners.find_each do |iapd_owner|
      process_owner iapd_owner
    end
  end

  def process_advisor(iapd_advisor)
    external_entity = ExternalEntity
                        .find_or_create_by!(dataset: 'iapd_advisors', external_data: iapd_advisor)
    # Iapd Advisors are linked via crd numbers that are stored as the dataset_id.
    # If the entity is not matched, this will automatically match the entity when there is
    # already a crd number associated with an existing entity
    unless external_entity.matched?
      match_by_crd_number(crd_number: iapd_advisor.dataset_id, external_entity: external_entity)
    end
  end

  def process_owner(iapd_owner)
    data = ExternalData::IapdOwner.new(iapd_owner.data)
    external_entity = ExternalEntity
                        .find_or_create_by!(dataset: 'iapd_owners',
                                            external_data: iapd_owner,
                                            primary_ext: data.primary_ext)

    unless external_entity.matched?
      match_by_crd_number(crd_number: iapd_owner.dataset_id, external_entity: external_entity)
    end

    create_owner_relationships(iapd_owner)
  end

  def match_by_crd_number(crd_number:, external_entity:)
    # For Iapd Owners, the dataset id is not always the crd number
    if ExternalLink.crd_number?(crd_number)
      external_link = ExternalLink.crd.find_by(link_id: crd_number)
      external_entity.update!(entity_id: external_link.entity_id) if external_link.present?
    end
  end

  def create_owner_relationships(iapd_owner)
    # data = ExternalData::IapdOwner.new(iapd_owner.data)
  end
end
