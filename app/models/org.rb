class Org < ActiveRecord::Base
  include SingularTable

  has_paper_trail :on => [:update, :destroy]

  belongs_to :entity, inverse_of: :org, touch: true

  before_create :set_entity_name

  COMMON_SUFFIXES = [
    'Inc',
    'Incorporated',
    'Company',
    'Co',
    'Cos',
    'Corp',
    'Corporation',
    'LLP',
    'LLC',
    'LP',
    'PA',
    'Chtd',
    'Chartered',
    'Companies',
    'Bancorp',
    'Bancorporation',
    'Ins',
    'Stores',
    'Holdings',
    'Group'
  ]

  def set_entity_name
    self.name = entity.name
  end

  def self.strip_name_punctuation(name)
    name.gsub(/\.(?!com)/i, '')
        .gsub(/[,"*]/, '')
        .gsub(/\s'/m, '')
        .gsub(/'\s/m, '')
        .gsub(/\s+/, ' ')    
  end

  def self.name_words_to_remove(remove_geo = false)
    words = ['the', 'and', 'of', 'for'].concat(COMMON_SUFFIXES).concat(Language::SCHOOLS).concat(Language::BUSINESS)
    words.concat(Language::REGIONS).concat(Language::GEOGRAPHY) if remove_geo
    words.uniq
  end 
 
  def self.strip_name(name, strip_geo = false)
    name = strip_name_punctuation(name)
    stripped = name
    name_words_to_remove(strip_geo).each do |word|
      stripped.gsub!(/\b#{word}\b/i, ' ')
    end
    stripped.gsub(/\s+/, ' ').strip
  end
end
