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
  has_one :person, inverse_of: :entity, dependent: :destroy
  has_one :org, inverse_of: :entity, dependent: :destroy
  has_one :couple, inverse_of: :entity, dependent: :destroy
  has_one :public_company, inverse_of: :entity, dependent: :destroy
  has_one :school, inverse_of: :entity, dependent: :destroy
  has_many :addresses, inverse_of: :entity, dependent: :destroy
  has_many :os_entity_transactions, inverse_of: :entity, dependent: :destroy
  has_many :extension_records, inverse_of: :entity, dependent: :destroy
  has_many :extension_definitions, through: :extension_records, inverse_of: :entities
  has_many :os_entity_categories, inverse_of: :entity
  has_many :os_categories, through: :os_entity_categories, inverse_of: :entities
  has_many :entity_fields, inverse_of: :entity, dependent: :destroy
  has_many :fields, through: :entity_fields, inverse_of: :entities
  has_many :article_entities, inverse_of: :entity, dependent: :destroy
  has_many :articles, through: :article_entities, inverse_of: :entities
  has_many :queue_entities, inverse_of: :entity, dependent: :destroy

  scope :people, -> { where(primary_ext: 'Person') }
  scope :orgs, -> { where(primary_ext: 'Org') }

  before_create :set_last_user_id
  after_create :create_primary_alias, :create_primary_ext

  def set_last_user_id
    self.last_user_id = Lilsis::Application.config.system_user_id unless self.last_user_id.present?
  end

  def create_primary_alias
    Alias.create(entity: self, name: name, is_primary: true, last_user_id: Lilsis::Application.config.system_user_id) unless aliases.where(is_primary: true).count > 0
  end

  def create_primary_ext
    fields = person? ? NameParser.parse_to_hash(name) : {}
    add_extension(primary_ext, fields)
  end

  def to_param
    "#{id}-#{name.parameterize}"
  end

  def person?
    primary_ext == 'Person'
  end  

  def org?
    primary_ext == 'Org'
  end

  def couple?
    primary_ext == 'Couple'
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
    extension_records.pluck(:definition_id)
  end
  
  def extension_names
    extension_ids.collect { |id| self.class.all_extension_names[id] }
  end

  def add_extension(name, fields={})
    fields.merge!(entity: self)
    ext = name.constantize.create(fields) if self.class.all_extension_names_with_fields.include?(name) and name.constantize.where(entity_id: id).count == 0
    def_id = ExtensionDefinition.find_by_name(name).id
    ExtensionRecord.find_or_create_by(entity_id: id, definition_id: def_id)
  end

  def self.with_exts(exts)
    ext_ids = exts.map { |ext| all_extension_names.index(ext) }.compact
    joins(:extension_records).where(extension_record: { definition_id: ext_ids })
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
      'Lawyer',
      'Couple'
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
      'PoliticalFundraising',
      'Couple'
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

  def featured_image_source_url
    return nil unless image = featured_image
    image.url
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

  def legacy_url(action = nil)
    self.class.legacy_url(primary_ext, id, name, action)
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

  def types
    extension_definitions.map(&:display_name)
  end

  def industries
    os_categories.map(&:industry_name).uniq
  end

  def name_regexes(require_first = true)
    if person?
      [person.name_regex(require_first)].concat(aliases.map { |a| a.name_regex(require_first) }).uniq.compact
    else
      []
    end
  end

  def all_field_details
    entity_fields.includes(:field)
  end

  def field_value(name)
    return nil unless details = field_details(name)
    details.value
  end

  def field_details(name)
    entity_fields.joins(:field).where(fields: { name: name }).first
  end

  def set_field(name, value, display_name = nil, type = "text")
    return false unless name.present? and value.present?

    EntityField.transaction do
      field = Field.find_or_create_by!(name: name) do |f|
        f.display_name = display_name.present? ? display_name : name.titleize
        f.type = type
      end

      ef = EntityField.find_or_initialize_by(entity: self, field: field)
      ef.update_attributes(value: value)
      ef
    end
  end

  def update_fields(hash)
    # underscore keys
    hash = Hash[hash.map { |k, v| [k.downcase.underscore.gsub(/\s+/, '_'), v] }]

    EntityField.transaction do
      # delete fields
      entity_fields.includes(:field).each do |ef|
        ef.delete if hash[ef.field.name].blank? or !hash.keys.include?(ef.field.name)
      end

      # update or create fields
      hash.each do |name, value|
        set_field(name, value)
      end
    end
  end

  def delete_field(name)
    ef.destroy if ef = field_details(name)
  end

  def map_field_values(field, value)
    if field == 'gender_id'
      v = {
        '1' => 'Female',
        '2' => 'Male',
        '3' => 'Other'
      }[value]
      k = 'gender'
    elsif field == 'party_id'
      v = Entity.where(id: value).pluck(:name).first
      k = 'party_affiliation'
    else
      k = field
      v = value
    end

    [k, v]
  end

  def update_fields_from_extensions
    return false unless id
    skip_cols = %w(id entity_id updated_at created_at name name_prefix name_first name_middle name_last name_suffix name_nick name_maiden)
    conn = ActiveRecord::Base.connection
    hash = {}
    self.class.all_extension_names_with_fields.each do |ext|
      sql = "SELECT * FROM #{ext.underscore} WHERE entity_id = #{id}"
      result = conn.execute(sql)
      if row = result.first
        row.each_with_index do |value, i|
          next unless value.present?
          col = result.fields[i]
          col, value = map_field_values(col, value)
          next if skip_cols.include?(col)
          hash[col] = value.to_s
        end
      end
    end
    hash
    update_fields(hash)
  end

  def update_fields_from_external_keys
    return false unless id
    hash = Hash[external_keys.joins(:domain).map { |k| [k.domain.name.downcase + "_id", k.external_id] }]
    update_fields(hash)
  end

  def self.create_couple(name, partner1, partner2)
    blurb = [partner1.blurb, partner2.blurb].compact.join('; ')
    blurb = nil unless blurb.present?

    e = create(
      name: name,
      blurb: blurb,
      primary_ext: 'Couple',
      last_user_id: Lilsis::Application.config.system_user_id
    )
    e.couple.partner1_id = partner1.id
    e.couple.partner2_id = partner2.id
    e.couple.save
    e
  end

  def self.find_couple(partner1_id, partner2_id)
    joins(:couple).where("(couple.partner1_id = ? AND couple.partner2_id = ?) OR (couple.partner1_id = ? AND couple.partner2_id = ?)", partner1_id, partner2_id, partner2_id, partner1_id).first
  end

  def couples
    Couple.where("couple.partner1_id = ? OR couple.partner2_id = ?", id, id)
  end

  def partners
    couples.map { |c| c.partner1_id == id ? c.partner2 : c.partner1 }
  end

  def add_image_from_url(url, force_featured = false)
    return if images.find { |i| i.url == url }
    image = Image.new_from_url(url)
    return false unless image
    image.title = name
    images << image
    image.feature if force_featured or !has_featured_image
    image
  end

  def featured_articles
    articles.where(article_entities: { is_featured: true} )
  end

  def add_article(hash, featured=true)
    article_entity = nil

    ActiveRecord::Base.transaction do
      article = Article.create(hash)
      article_entity = ArticleEntity.create(
        article_id: article.id,
        entity_id: id,
        is_featured: featured
      )
    end

    article_entity
  end
end