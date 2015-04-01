require 'street_address'

class Address < ActiveRecord::Base
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :addresses
  belongs_to :state, class_name: "AddressState", inverse_of: :addresses

  validates_presence_of :city, :country_name

  def to_s
    "#{street1}, #{street2}, #{street3}, #{city}, #{state.present? ? state.abbreviation: ''} #{postal}, #{country_name}".strip.gsub(/\s+,/, " ").gsub(/\s+/, " ")
  end

  def self.parse(str, data = {})
    a = new
    a.parse(str)
    a.attributes = data if a.parsed.nil? and data.count > 0
    a
  end

  def parse(str = nil)
    str = str.present? ? str : to_s
    str.gsub!(/\s+/, " ").strip!
    @raw = str
    @parsed = StreetAddress::US.parse(str, informal: false)

    unless @parsed.nil? or @parsed.state.nil?
      parse_street
      self.city = @parsed.city
      self.state = AddressState.find_by(abbreviation: @parsed.state.upcase)
      self.postal = @parsed.postal_code
      self.country_name = "United States"
    end

    titleize
  end

  def raw
    @raw
  end

  def parsed
    @parsed
  end

  def parse_street
    unless parsed.nil?
      self.street1 = "#{parsed.number} #{parsed.prefix} #{parsed.street} #{parsed.street_type}".strip.gsub(/\s+/, " ")

      unless parsed.unit.nil?
        self.street2 = "#{parsed.unit_prefix} #{parsed.unit}".strip
      end
    end

    if (match = street1.match(/ \d+$/)) and street2.nil?
      self.street2 = match[0].strip
      self.street1.gsub!(/\d+$/, "").strip!
    end    
  end

  def titleize
    %w(street1 street2 street3 city).each do |field|
      value = send(field.to_sym)
      next unless value.is_a?(String)
      send(:"#{field}=", value.titleize)
    end

    self
  end

  def comparison_hash
    return nil unless area_hash.present?
    return street1_hash + ":" + area_hash if street1_hash.present?
    return area_hash
  end

  def street1_hash
    return nil unless street1.present?
    #street hash is concatenation of first 2-3 street1 parts, depending on whether there's a street prefix
    num = street_prefix? ? 2 : 1
    street1.gsub('.', '').split(" ")[0..num].join.downcase
  end

  def area_hash
    return postal[0..4] if postal.present?
    city.downcase + ":" + country_name.downcase
  end

  def street_prefix?
    parse unless parsed

    if parsed.nil?
      parts = street1.gsub('.', '').split(" ")
      return false if parts.count < 3
      # if second part of street1 is a direction and third part is not a street type
      %w(w n e s west north east west nw ne sw se).include?(parts[1].downcase) and !StreetAddress::US::STREET_TYPES_LIST.keys.include?(parts[2].downcase)
    else
      !parsed.prefix.nil?
    end
  end

  def same_as?(address)
    return false unless comparison_hash and address.comparison_hash
    (to_s == address.to_s) or (comparison_hash == address.comparison_hash)
  end

  def street2_from(address)
    street2 = address.street2 if same_as?(address) and street2.blank? and address.street2.present?
  end

  def add_street_view_image_to_entity(width = 640, height=640, crop = true)
    return nil unless street1 and city
    location = to_s
    caption = 'street view: ' + obfuscated
    size = "#{width}x#{height}"
    url = "https://maps.googleapis.com/maps/api/streetview?size=#{size}&location=#{URI::encode(location)}"
    image = entity.add_image_from_url(url, force_featured = false, caption)
    image.crop(0, 0, width-40, height-40) if image.present? and crop # in order to remove google branding
    image
  end

  def obfuscated
    str = city
    str += ", " + state_abbr(state_name) if state_name
    str += " " + postal if postal
    str += ", " + country_name unless ['United States', 'U.S.', 'US', 'USA'].include?(country_name)
    str  
  end

  def state_abbr(name)
    abbr = STATE_ABBR.key(name)
    return abbr unless abbr.nil?
    name
  end

  STATE_ABBR = {
    'AL' => 'Alabama',
    'AK' => 'Alaska',
    'AZ' => 'Arizona',
    'AR' => 'Arkansas',
    'CA' => 'California',
    'CO' => 'Colorado',
    'CT' => 'Connecticut',
    'DE' => 'Delaware',
    'FL' => 'Florida',
    'GA' => 'Georgia',
    'HI' => 'Hawaii',
    'ID' => 'Idaho',
    'IL' => 'Illinois',
    'IN' => 'Indiana',
    'IA' => 'Iowa',
    'KS' => 'Kansas',
    'KY' => 'Kentucky',
    'LA' => 'Louisiana',
    'ME' => 'Maine',
    'MD' => 'Maryland',
    'MA' => 'Massachusetts',
    'MI' => 'Michigan',
    'MN' => 'Minnesota',
    'MS' => 'Mississippi',
    'MO' => 'Missouri',
    'MT' => 'Montana',
    'NE' => 'Nebraska',
    'NV' => 'Nevada',
    'NH' => 'New Hampshire',
    'NJ' => 'New Jersey',
    'NM' => 'New Mexico',
    'NY' => 'New York',
    'NC' => 'North Carolina',
    'ND' => 'North Dakota',
    'OH' => 'Ohio',
    'OK' => 'Oklahoma',
    'OR' => 'Oregon',
    'PA' => 'Pennsylvania',
    'RI' => 'Rhode Island',
    'SC' => 'South Carolina',
    'SD' => 'South Dakota',
    'TN' => 'Tennessee',
    'TX' => 'Texas',
    'UT' => 'Utah',
    'VT' => 'Vermont',
    'VA' => 'Virginia',
    'WA' => 'Washington',
    'WV' => 'West Virginia',
    'WI' => 'Wisconsin',
    'WY' => 'Wyoming'
  }  
end