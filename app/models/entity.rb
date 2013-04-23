class Entity < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  has_many :images, inverse_of: :entity, dependent: :destroy
  has_many :list_entities, inverse_of: :entity, dependent: :destroy
  has_many :lists, through: :list_entities
  has_many :links, foreign_key: "entity1_id", inverse_of: :entity, dependent: :destroy
  has_many :reverse_links, class_name: "Link", foreign_key: "entity2_id", inverse_of: :related, dependent: :destroy
  has_many :relationships, through: :links
  has_many :relateds, through: :links
  has_many :interlocks, through: :related, source: :related

  def person?
    primary_ext == "Person"
  end  

  def org?
    primary_ext == "Org"
  end  

  def all_attributes
    hash = attributes.merge!(extension_attributes).reject { |k,v| v.nil? }
    hash.delete(:notes)
    hash
  end
  
  def extension_attributes
    hash = {}
    (extension_names & self.class.all_extension_names_with_fields).each do |name|
      ext = Kernel.const_get(name).where(:entity_id => id).first
      ext_hash = ext.attributes
      hash.merge!(ext_hash)
    end
    hash.delete("id")
    hash.delete(:id)
    hash.delete("entity_id")
    hash.delete(:entity_id)
    hash
  end

  def extension_ids
    ExtensionRecord.select(:definition_id).where(:entity_id => id).collect { |er| er.definition_id }
  end
  
  def extension_names
    extension_ids.collect { |id| self.class.all_extension_names[id] }
  end
  
  def self.all_extension_names    
    [
      'None',
      'Person',
      'Org',
      'PoliticalCandidate',
      'ElectedRepresentative',
      'Business',
      'GovernmentBody',
      'School',
      'MembershipOrg',
      'Philanthropy',
      'NonProfit',
      'PoliticalFundraising',
      'PrivateCompany',
      'PublicCompany',
      'IndustryTrade',
      'LawFirm',
      'LobbyingFirm',
      'PublicRelationsFirm',
      'IndividualCampaignCommittee',
      'Pac',
      'OtherCampaignCommittee',
      'MediaOrg',
      'ThinkTank',
      'Cultural',
      'SocialClub',
      'ProfessionalAssociation',
      'PoliticalParty',
      'LaborUnion',
      'Gse',
      'BusinessPerson',
      'Lobbyist',
      'Academic',
      'MediaPersonality',
      'ConsultingFirm',
      'PublicIntellectual',
      'PublicOfficial',
      'Lawyer'
    ]
  end
  
  def self.all_extension_names_with_fields
    [
      'Person',
      'Org',
      'PoliticalCandidate',
      'ElectedRepresentative',
      'Business',
      'School',
      'PublicCompany',
      'GovernmentBody',
      'BusinessPerson',
      'Lobbyist',
      'PoliticalFundraising'
    ]
  end

  def related_essential_words
    words = []
    relateds.where("link.category_id = 1").where(primary_ext: "Org").each do |related|
      words.concat(OrgName.essential_words(related.name))
    end
    words.uniq
  end

  def google_image_search_result_urls(page=1, filter_with_related=false)
    key = Lilsis::Application.config.google_custom_search_key
    engine_id = Lilsis::Application.config.google_custom_search_engine_id
    start = 1 + (10 * (page - 1))

    query = '"' + name + '"'

    url = "https://www.googleapis.com/customsearch/v1?" + {
      key: key,
      cx: engine_id,
      q: query,
      imgSize: "xxlarge",
      imgType: "face",
      start: start
    }.to_query
print url + "\n"    
    JSON::parse(open(url).read)["items"].collect do |i| 
      if i["pagemap"].nil? ||  i["pagemap"]["cse_image"].nil?
        nil
      elsif filter_with_related && (i["snippet"].split(/[\.,\-\/\s]/).map(&:downcase) & related_essential_words.take(20)).empty?
        nil
      else
        i["pagemap"]["cse_image"].first["src"]
      end      
    end.reject(&:nil?)
  end
end