# frozen_string_literal: true

class RelationshipValidator < ActiveModel::Validator
  def self.valid_categories
    @valid_categories ||= RelationshipCategory.valid_categories.freeze
  end

  [:person_to_person, :person_to_org, :org_to_org, :org_to_person].each do |sym|
    define_singleton_method(sym) { valid_categories.fetch(sym) }
  end

  def validate(rel)
    return if skip_validate?(rel)

    if rel.entity.person? && rel.related.person?

      unless self.class.person_to_person.include?(rel.category_id)
        rel.errors.add :category, error_msg(rel.category_id, 'Person to Person')
      end

    elsif rel.entity.person? && rel.related.org?

      unless self.class.person_to_org.include?(rel.category_id)
        rel.errors.add :category, error_msg(rel.category_id, 'Person to Org')
      end

    elsif rel.entity.org? && rel.related.org?

      unless self.class.org_to_org.include?(rel.category_id)
        rel.errors.add :category, error_msg(rel.category_id, 'Org to Org')
      end

    elsif rel.entity.org? && rel.related.person?

      unless self.class.org_to_person.include?(rel.category_id)
        rel.errors.add :category, error_msg(rel.category_id, 'Org to Person')
      end

    end
  end

  private

  def skip_validate?(rel)
    return true if rel.is_deleted_changed? && rel.persisted?
    return true unless rel.entity1_id.present? && rel.entity2_id.present? && rel.category_id.present?
  end

  def error_msg(cat_id, rel_direction)
    "#{Relationship.all_categories[cat_id]} is not a valid category for #{rel_direction} relationships"
  end
end
