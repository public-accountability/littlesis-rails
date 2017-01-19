module RelationshipDisplay
  extend ActiveSupport::Concern
  # included do end
  module ClassMethods
  end

  # Returns an array of the names of the description1 and decription2 fields
  DESCRIPTION_FIELDS_DISPLAY_NAMES = {
    1 => ['Position belongs to', 'Position in'],
    2 => ['Student', 'School'],
    3 => ['Member', 'Organization'],
    7 => ['Lobbyist/firm', 'Politician/agency'],
    10 => ['Owner', 'Organization'],
    11 => ['Child', 'Parent']
  }.freeze

  # This provides an array of text that goes after Entity one's name 
  # and after Entity two's name
  # Links are generated in the view.
  def description_sentence
    case category_id
    when Relationship::POSITION_CATEGORY
      [ " #{has_had} a position#{title_in_parens}at ", "" ]
    when Relationship::EDUCATION_CATEGORY
      [ " #{is_was} a student of ", ""]
    when Relationship::MEMBERSHIP_CATEGORY
      [ " #{is_was} a member of ", ""]
    when Relationship::FAMILY_CATEGORY
      [ " and ", " #{are_were} in a family" ]
    when Relationship::DONATION_CATEGORY
      [ " gave money to ", ""]
    when Relationship::TRANSACTION_CATEGORY
      [ " and ", " #{did_do} business" ]
    when Relationship::LOBBYING_CATEGORY
      [ " #{lobbies_lobbied} ", ""]
    when Relationship::SOCIAL_CATEGORY
      if !description1.nil? and description1 == description2
        [ " and ", " #{are_were} #{description1.pluralize}" ]
      else
        [ " and ", " #{have_had} a social relationship" ]
      end
    when Relationship::PROFESSIONAL_CATEGORY
      if !description1.nil? and description1 == description2
        [ " and ", " #{are_were} #{description1.pluralize}" ]
      else
        [ " and ", " #{have_had} a professional relationship" ]
      end
    when Relationship::OWNERSHIP_CATEGORY
      [ " #{is_was} an owner of ", ""]
    when Relationship::HIERARCHY_CATEGORY
      [ " and ", " #{have_had} a hierarchical relationship" ]
    else
      [" and ", " #{have_had} a generic relationship"]
    end
  end
  
  def has_had
    RelationshipDisplay.is_current_helper('has', 'had').call(is_current)
  end
  
  def have_had
    RelationshipDisplay.is_current_helper('have', 'had').call(is_current)
  end

  def is_was
    RelationshipDisplay.is_current_helper('is', 'was').call(is_current)
  end

  def are_were
    RelationshipDisplay.is_current_helper('are','were').call(is_current)
  end
  
  def did_do
    RelationshipDisplay.is_current_helper('did', 'do').call(is_current)
  end

  def lobbies_lobbied
    RelationshipDisplay.is_current_helper('lobbies', 'lobbied').call(is_current)
  end

  def self.is_current_helper(true_verb, false_verb)
    lambda do |is_current|
      if is_current == true
        true_verb
      elsif is_current == false
        false_verb
      else
        true_verb + '/' + false_verb
      end
    end
  end

  def title_in_parens
    title.nil? ? ' ' : " (#{title}) "
  end
end
