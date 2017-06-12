class RelationshipValidator < ActiveModel::Validator
  VALID_CATEGORIES = RelationshipCategory.valid_categories.freeze
  PERSON_TO_PERSON = VALID_CATEGORIES[:person_to_person]
  PERSON_TO_ORG = VALID_CATEGORIES[:person_to_org]
  ORG_TO_ORG = VALID_CATEGORIES[:org_to_org]
  ORG_TO_PERSON = VALID_CATEGORIES[:org_to_person]
  
  def validate(rel)
    return unless rel.entity1_id.present? && rel.entity2_id.present? && rel.category_id.present?

    if rel.entity.person? && rel.related.person?
      unless RelationshipValidator::PERSON_TO_PERSON.include?(rel.category_id)
        rel.errors[:category] << error_msg(rel.category_id, 'Person to Person')
      end
    end

    
  end

  private
  
  def error_msg(cat_id, rel_direction)
    "#{Relationship.all_categories[cat_id]} is a not a valid category for #{rel_direction} relationships"
  end
  
end
