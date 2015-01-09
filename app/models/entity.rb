class Entity < ActiveRecord::Base
  include SingularTable
  include SoftDelete
  include Cacheable

  self.default_timezone = :local
  self.skip_time_zone_conversion_for_attributes = [:created_at, :updated_at]

  has_many :aliases, inverse_of: :entity, dependent: :destroy
  has_many :images, inverse_of: :entity, dependent: :destroy
  has_many :list_entities, inverse_of: :entity, dependent: :destroy
  has_many :lists, -> { where(is_network: false) }, through: :list_entities
  has_many :networks, -> { where(is_network: true) }, class_name: "List", through: :list_entities, source: :list
  has_many :links, foreign_key: "entity1_id", inverse_of: :entity, dependent: :destroy
  has_many :reverse_links, class_name: "Link", foreign_key: "entity2_id", inverse_of: :related, dependent: :destroy
  has_many :relationships, through: :links
  has_many :relateds, through: :links
  has_many :groups, through: :lists, inverse_of: :entities
  has_many :campaigns, through: :groups, inverse_of: :entities
  has_many :note_entities, inverse_of: :entity
  has_many :notes, through: :note_entities, inverse_of: :entities
  belongs_to :last_user, class_name: "SfGuardUser", foreign_key: "last_user_id", inverse_of: :edited_entities
  has_many :external_keys, inverse_of: :entity, dependent: :destroy
  has_one :public_company, inverse_of: :entity, dependent: :destroy

  scope :people, -> { where(primary_ext: 'Person') }
  scope :orgs, -> { where(primary_ext: 'Org') }

  def person?
    primary_ext == 'Person'
  end  

  def org?
    primary_ext == 'Org'
  end  

  def other_ext
    person? ? 'Org' : 'Person'
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

  def default_image_url
    return "/images/system/anon.png" if person?
    "/images/system/anons.png"
  end

  def has_featured_image
    images.featured.count > 0
  end

  def featured_image
    images.featured.first
  end

  def featured_image_url(type=nil)
    image = featured_image
    return default_image_url if image.nil?
    type = (image.has_square ? "square" : "profile") if type.nil?
    image.image_path(type)
  end

  def relateds_by_count(num=5, primary_ext=nil)
    r = relateds.select("entity.*, COUNT(link.id) AS num").group("link.entity2_id").order("num DESC").limit(num)
    r.where("entity.primary_ext = ?", primary_ext) unless primary_ext.nil?
    r
  end

  def interlocks_by_count(options={}, only_count=false)
    order1 = options[:order1]
    order2 = options[:order2]
    cat1_ids = options[:cat1_ids]
    cat2_ids = options[:cat2_ids]
    ext2_ids = options[:ext2_ids]
    past1 = options[:past1]
    past2 = options[:past2]
    num = options[:num] || 20
    max_num = options[:max_num]
    page = options[:page]

    r = Link.select("link2.entity2_id AS degree2_id, GROUP_CONCAT(DISTINCT link2.entity1_id) AS degree1_ids, COUNT(DISTINCT link2.entity1_id) AS num")
      .joins("LEFT JOIN link AS link2 ON link.entity2_id = link2.entity1_id")
      .where("link.entity1_id = ?", id)
      .where("link2.entity2_id <> ?", id)
      .group("link2.entity2_id")
      .order("num DESC")

    r = r.where("link.is_reverse = ?", (order1 == 2)) if order1.present?
    r = r.where("link2.is_reverse = ?", (order2 == 2)) if order2.present?

    r = r.where("link.category_id" => cat1_ids) if cat1_ids.present?
    r = r.where("link2.category_id" => cat2_ids) if cat2_ids.present?

    if ext2_ids.present?
      r = r.joins("LEFT JOIN entity e ON e.id = link2.entity2_id LEFT JOIN extension_record er ON er.entity_id = e.id")
      r = r.where("er.definition_id" => ext2_ids)
    end

    if past1.present?
      r = r.joins("LEFT JOIN relationship r1 ON r1.id = link.relationship_id")
      r = r.where("(r1.is_current = 1 OR r1.is_current IS NULL) AND r1.end_date IS NULL")
    end

    if past2.present?
      r = r.joins("LEFT JOIN relationship r2 ON r2.id = link2.relationship_id")
      r = r.where("(r2.is_current = 1 OR r2.is_current IS NULL) AND r2.end_date IS NULL")
    end

    if only_count
      r = r.select("COUNT(DISTINCT l2.entity2_id)")
      r = r.group(nil)
      r = r.order(nil)
    else
      num = [num, max_num].min if max_num.present?
      r = r.limit(num) if num.present?
      r = r.offset(num * (page-1)) if page.present?
    end

    return r.first if only_count

    entities = r.to_a.collect do |row|
      entity = Entity.find(row[:degree2_id])
      { entity: entity, degree1_num: row[:num], degree1_ids: row[:degree1_ids] }
    end

    entities
  end

  def self.rubin # :)
    find(1164)
  end

  def self.name_to_legacy_slug(name)
    name.gsub(" ", "_").gsub("/", "~")
  end

  def name_to_legacy_slug
    self.class.name_to_legacy_slug(name)
  end

  def legacy_url
    self.class.legacy_url(primary_ext, id, name)
  end

  def self.legacy_url(primary_ext, id, name, action = nil)
    url = "/" + primary_ext.downcase + "/" + id.to_s + "/" + name_to_legacy_slug(name)
    url += "/" + action if action.present?
    url
  end

  def last_new_user
    last_user.user
  end

  def name_without_initials
    name.gsub('.', '').split(' ').select { |part| part.length > 1 }.join(' ')
  end

  def affiliations
    relateds.where('link.category_id IN (1, 3)')
  end

  def twitter_ids
    keys = external_keys.where(domain_id: Domain::TWITTER_ID)
    return nil unless keys.present?
    keys.collect(&:external_id)
  end
end