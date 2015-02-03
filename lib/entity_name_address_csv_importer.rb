require 'street_address'

class EntityNameAddressCsvImporter

  attr_accessor :first, :middle, :last, :prefix, :suffix, :raw_name, :maiden,
                :street, :unit, :city, :state, :postal, :postal_ext, :country, :raw_address, :address,
                :image, :news, :profession, :row, :status, :common_name_type, :address_type

  def initialize(row)
    @first, @last, @street, @city, @state, @postal, @country, @image, @news, @profession = @row = row.map { |d| d.nil? ? nil : d.gsub(/[\r\n\s]+/, " ").strip }
    @raw_name = (@first.to_s + " " + @last.to_s).strip
    @entity = nil
    @address = nil
    @matches = { 
      name: [],
      alias: [],
      address: [],
      postal: [],
      arts: [],
      list: [],
      previous: []
    }
    @address_type = nil
    @common_name_type = nil
    @last_user_id = 2
  end

  def already_imported_ids(ids)
    @already_imported_ids = ids
  end

  def collector_list_ids(ids)
    @collector_list_ids = ids
  end

  def arts_related_ids(ids)
    @arts_related_ids = ids
  end

  def import
    return false if skip_data
    clean_data
    match_or_create_entity
    create_image
    create_address
    entity
  end

  def skip_data
    @status = :skipped

    # skip missing name data
    return true if @first.blank? or @last.blank?

    # skip header row
    return true if @first.downcase == "first name" or @last.downcase == "last name"

    # skip couples for now
    return true if @raw_name.match(/&|\band\b/)

    @status = :unknown
    false
  end

  def encode(str)
    str.encode("iso-8859-1").force_encoding("utf-8")
  end

  def clean_data
    parse_first_name
    parse_last_name
    parse_address
  end

  def parse_first_name
    @first.gsub!(".", "")

    nick_regex = /".+"|'.+'|\(.+\)/
    if nick = @first.match(nick_regex)
      @nick = nick[0][1..-2]
      @first.gsub!(nick_regex, "").strip!.gsub!(/\s+/, " ")
    end

    parts = @first.split(/\s/)

    if parts.count > 1 and parts.last.length == 1
      @middle = parts.last
      @first = parts[0..-2].join(" ")
    end
  end

  def parse_last_name
    maiden_regex = /\((.+)\)/
    if maiden = @last.match(maiden_regex)
      @maiden = maiden[1]
      @last.gsub!(maiden_regex, "").strip!.gsub!(/\s+/, " ")
    end
  end

  def parse_address
    return unless @street and @city and @state and @postal
    return unless !@country.nil? and ["united states", "us", "u.s.", "usa", "u.s.a."].include?(@country.downcase)
    @raw_address = "#{@street}, #{@city}, #{@state} #{@postal}, #{@country}"
    oneliner = "#{@street}, #{@city}, #{@state} #{@postal}"
    @address = Address.parse(oneliner, { 
      street1: @street,
      city: @city,
      state: AddressState.find_by(abbreviation: @state.upcase)
    })
  end

  def add_matches(entities, type)
    return false unless entities.present?
    ids = @matches[type].map(&:id)
    @matches[type].concat(entities.select { |e| !ids.include?(e.id) })
    @status = :matched
    true
  end

  def entity
    match? ? match : @entity
  end

  def match
    entities = all_matches
    return nil unless entities.count == 1
    entities.first
  end

  def matches
    @matches
  end

  def all_matches
    @matches.map { |type, entities| entities }.flatten.uniq { |e| e.id }
  end

  def name_matches
    @matches[:name] or []
  end

  def alias_matches
    @matches[:alias] or []
  end

  def address_matches
    @matches[:address] or []
  end

  def address_match?
    address_matches.count == 1
  end

  def postal_match?
    postal_matches.count == 1
  end

  def postal_matches
    @matches[:postal] or []
  end

  def arts_matches
    @matches[:arts] or []
  end

  def arts_match?
    arts_matches.count == 1
  end

  def list_matches
    @matches[:list] or []
  end

  def list_match?
    list_matches.count == 1
  end

  def previous_import?
    (@matches[:previous] or []).count == 1
  end

  def match_count
    all_matches.count
  end

  def skipped?
    @status == :skipped
  end

  def matched?
    @status == :matched
  end

  def match?
    match_count == 1
  end

  def matches?
    match_count > 1
  end

  def match_type
    return nil unless match?
    @matches.keys.first
  end

  def common_name?
    @status == :common_name
  end

  def match_or_create_entity
    match_name
    match_parsed_raw_name
    match_aliases
    check_already_imported
    check_collector_list unless previous_import?

    unless list_match? or previous_import?
      match_address if matched?
      check_arts_organizations if matched? and !address_match?
      unmatch_common_name unless address_match? or arts_match?
    end
    
    create_entity unless match?
  end

  def match_name
    entities = EntityMatcher.by_person_name(@first, @last, @middle, @suffix, @nick, @maiden)
    add_matches(entities, :name)
  end

  def match_parsed_raw_name
    name = NameParser.new(@raw_name)
    entities = EntityMatcher.by_person_name(name.first, name.last, name.middle, name.suffix, name.nick)
    add_matches(entities, :name)
  end

  def match_aliases
    entities = Entity.joins(:aliases).where("LOWER(alias.name) = ?", @raw_name.downcase)
    add_matches(entities, :alias)
  end

  def check_already_imported
    return unless matched?
    return unless @already_imported_ids.present?
    entity = all_matches.find { |e| @already_imported_ids.include?(e.id) }
    @matches = { previous: [entity] } if entity.present?
  end

  def check_collector_list
    return unless matched?
    return unless @collector_list_ids.present?
    entities = all_matches.select { |e| @collector_list_ids.include?(e.id) }
    @matches = { list: entities } if entities.present?
  end

  def check_arts_organizations
    return unless matched?
    return unless @arts_related_ids.present?
    entities = all_matches.select { |e| @arts_related_ids.include?(e.id) }
    @matches = { arts: entities } if entities.present?
  end

  def match_address
    return unless matched?
    return unless @address and @address.street1 and @address.postal

    entities = all_matches.select do |match|
      if match.addresses.find { |a| a.same_as?(@address) }
        @address_type = :existing_address
        true
      elsif OpensecretsAddressImporter.new(match).addresses.find { |a| a.same_as?(@address) }
        @address_type = :opensecrets_address
        true
      else
        false
      end
    end

    if entities.present?
      @matches = { address: entities } 
    # elsif @postal # and !COMMON_POSTAL_CODES.include?(@postal)
    #   entities = all_matches.select do |match|
    #     match.addresses.find { |a| a.postal == @postal }
    #   end

    #   if entities.present?
    #     @matches = { postal: entities } 
    #   end
    end
  end

  def create_entity
    @entity = Entity.new(
      name: [@first, @middle, @last, @suffix].join(" ").strip.gsub(/\s+/, " "),
      primary_ext: "Person",
      last_user_id: @last_user_id
    )

    @entity.person = Person.new(
      name_prefix: @prefix,
      name_first: @first,
      name_middle: @middle,
      name_last: @last,
      name_suffix: @suffix,
      name_nick: @nick,
      name_maiden: @maiden
    )

    if @maiden
      @entity.aliases << Alias.new(name: [@prefix, @first, @middle, @maiden, @suffix].join(" ").strip.gsub(/\s+/, " "))
    end

    @status = :created
  end

  def create_image(force_featured = false)
    return unless e = entity
    return unless @image
    return if e.images.find { |i| i.url == @image }
    image = Image.new_from_url(@image)
    return unless image
    image.title = e.name
    image.is_featured = (force_featured or !e.has_featured_image)
    # e.association(:images).add_to_target(image)
    e.images << image
  end

  def create_address
    return unless e = entity
    return unless @address and @address.is_a?(Address) and @address.valid?
    return if e.addresses.find { |a| a.same_as?(@address) }
    # e.association(:addresses).add_to_target(@address)
    e.addresses << @address
  end

  def unmatch_common_name
    return if address_match?
    return unless match?

    match = all_matches.first

    if match.person.name_first.length == 1 and common_last_name?(match)
      @status = :common_name
      @common_name_type = :init_last
    elsif common_first_name?(match) and common_last_name?(match)
      @status = :common_name
      @common_name_type = :first_last
    elsif common_first_name?(match) and multiple_last_names?(match)
      @status = :common_name
      @common_name_type = :first_multiple
    end
  end

  def common_first_name?(entity)
    COMMON_FIRST_NAMES.include?(entity.person.name_first.downcase)
  end

  def common_last_name?(entity)
    COMMON_LAST_NAMES.include?(entity.person.name_last.downcase)
  end

  def multiple_last_names?(entity)
    Person.where("LOWER(name_last) = LOWER(?)", entity.person.name_last).count > 1
  end

  COMMON_FIRST_NAMES = ["john", "david", "robert", "michael", "james", "william", "richard", "thomas", "mark", "paul", "charles", "peter", "joseph", "stephen", "george", "daniel", "steven", "andrew", "jeffrey", "edward", "scott", "mary", "christopher", "brian", "kevin", "susan", "gary", "donald", "j", "frank", "kenneth", "timothy", "alan", "steve", "patrick", "tom", "jim", "eric", "ronald", "elizabeth", "bill", "bruce", "mike", "matthew", "jonathan", "douglas", "anthony", "jack", "nancy", "philip", "lawrence", "gregory", "barbara", "chris", "larry", "karen", "martin", "dennis", "patricia", "linda", "henry", "joe", "lisa", "roger", "dan", "anne", "jeff", "howard", "arthur", "jennifer", "w", "ann", "bob", "r", "walter", "jay", "craig", "carl", "carol", "tim", "barry", "jerry", "keith", "jane", "samuel", "amy", "margaret", "marc", "greg", "gerald", "laura", "sarah", "deborah", "fred", "jon", "jason", "harry", "kathleen", "adam", "raymond"]
  
  COMMON_LAST_NAMES = ["smith", "johnson", "brown", "miller", "williams", "davis", "jones", "wilson", "anderson", "taylor", "white", "thompson", "lee", "martin", "harris", "moore", "clark", "cohen", "lewis", "thomas", "murphy", "walker", "kelly", "king", "baker", "allen", "young", "roberts", "hall", "campbell", "wright", "sullivan", "jackson", "robinson", "green", "adams", "mitchell", "fisher", "morgan", "rogers", "collins", "stewart", "nelson", "ryan", "scott", "hill", "kennedy", "evans", "phillips", "bell", "morris", "cooper", "schwartz", "edwards", "ross", "rose", "parker", "carter", "murray", "marshall", "ford", "cook", "jacobs", "levy", "turner", "gordon", "friedman", "reed", "wood", "hughes", "walsh", "alexander", "shapiro", "stone", "hunt", "howard", "bennett", "cole", "peterson", "foster", "gray", "fox", "bailey", "meyer", "lynch", "klein", "watson", "cox", "james", "brooks", "perry", "coleman", "ward", "o'brien", "price", "kaplan", "graham", "mccarthy", "burke", "wallace"]

  COMMON_POSTAL_CODES = ["10022", "10019", "10017", "10036", "20005", "20004", "77002", "77056", "60606", "45202", "20036", "20006", "20001", "60601", "75201", "60015", "10005", "75039", "60045", "08540", "06830", "44114", "20817", "06905", "19103", "10004", "30339", "90245", "60610", "80112", "63105", "28202", "89109", "20016", "60563", "94104", "75024", "22042", "10021", "20002", "63101", "30309", "22102", "19087", "80202", "95054", "76102", "11747", "20190", "94105", "92121", "10018", "75240"]  
end