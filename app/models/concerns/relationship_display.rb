module RelationshipDisplay
  extend ActiveSupport::Concern
  # included do end
  module ClassMethods
  end

  # This provides an array of text that goes after Entity one's name 
  # and  after Entity two's name
  # Links are generated in the view. 
  def description_sentence
    case category_id
    when Relationship::POSITION_CATEGORY
      [ " #{has_had} a position#{title_in_parens}at ", "" ]
    when Relationship::EDUCATION_CATEGORY
      
    when Relationship::MEMBERSHIP_CATEGORY

    when Relationship::FAMILY_CATEGORY

    when Relationship::DONATION_CATEGORY

    when Relationship::TRANSATION_CATEGORY

    when Relationship::LOBBYING_CATEGORY

    when Relationship::SOCIAL_CATEGORY

    when Relationship::PROFESSIONAL_CATEGORY

    when Relationship::OWNERSHIP_CATEGORY

    when Relationship::HIERARCHY_CATEGORY

    when Relationship::GENERIC_CATEGORY   
    else
    end
  end  
  
  def has_had
    if is_current == true
      'has'
    elsif is_current == false
      'had'
    else
      'has/had'
    end
  end
  
  def title_in_parens
    title.nil? ? "" : " (#{title}) "
  end
  
end
