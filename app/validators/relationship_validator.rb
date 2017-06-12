class RelationshipValidator < ActiveModel::Validator
  VALID_CATEGORIES = RelationshipCategory.valid_categories.freeze
  
  def validate(record)
  end

  
end

