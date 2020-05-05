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

  def process_advisor(external_data)
    external_entity = ExternalEntity
                        .find_or_create_by!(dataset: 'iapd_advisors', external_data: external_data)
    # Iapd Advisors are linked via crd numbers that are stored as the dataset_id.
    # If the entity is not matched, this will automatically match the entity when there is
    # already a crd number associated with an existing entity
    unless external_entity.matched?
      match_by_crd_number(crd_number: external_data.dataset_id, external_entity: external_entity)
    end
  end

  # input: ExternalData
  def process_owner(external_data)
    data = ExternalData::IapdOwner.new(external_data.data)
    external_entity = ExternalEntity
                        .find_or_create_by!(dataset: 'iapd_owners',
                                            external_data: external_data,
                                            primary_ext: data.primary_ext)

    unless external_entity.matched?
      match_by_crd_number(crd_number: external_data.dataset_id, external_entity: external_entity)
    end

    create_owner_relationships(owner_data: data,
                               external_entity: external_entity,
                               external_data: external_data)
  end

  def match_by_crd_number(crd_number:, external_entity:)
    # For Iapd Owners, the dataset id is not always the crd number.
    if ExternalLink.crd_number?(crd_number)
      external_link = ExternalLink.crd.find_by(link_id: crd_number)
      external_entity.update!(entity_id: external_link.entity_id) if external_link.present?
    end
  end

  # Schedule A includes both major owners (i.e. shareholders > 5%) and execute officers.
  # This creates one or two ExternalRelationship, depending if the iapd_owner is executive and an owner
  # or just an executive.
  def create_owner_relationships(owner_data:, external_entity:, external_data:)
    owner_data.advisor_relationships.each do |hash|
      raise NotImplementedError, 'Cannot handle Schedule B Relationships' if hash['schedule'] == 'B'

      # if unmatched one or both of these will be nil which is okay
      entity1_id = external_entity.entity_id
      entity2_id = ExternalLink.crd.find_by(link_id: hash['advisor_crd_number'].to_s)&.entity_id

      title = hash['title_or_status']
      is_board = title&.downcase&.include? 'member'
      relationship_attributes = { description1: title, position_attributes: { is_board: is_board } }

      position = ExternalRelationship
        .iapd_owners
        .find_or_create_by!(external_data: external_data,
                            category_id: Relationship::POSITION_CATEGORY,
                            entity1_id: entity1_id,
                            entity2_id: entity2_id)

      position.update!(relationship_attributes: position.relationship_attributes.deep_merge(relationship_attributes))

      # Ownership codes (from page 29 of the form adv)
      #   NA    Less than 5%   C     25-50
      #   A     5-10%          D     50-75
      #   B     10-25%         E     75%+
      if %W[A B C D E].include?(hash['ownership_code'])
       ownership = ExternalRelationship
                     .iapd_owners
                     .find_or_create_by!(external_data: external_data,
                                         category_id: Relationship::OWNERSHIP_CATEGORY,
                                         entity1_id: entity1_id,
                                         entity2_id: entity2_id)
      end
    end
  end
end
