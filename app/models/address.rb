# frozen_string_literal: true

class Address < ApplicationRecord
  include SingularTable
  include SoftDelete

  belongs_to :entity, inverse_of: :addresses
  belongs_to :state, class_name: "AddressState", inverse_of: :addresses, optional: true
  has_many :images, inverse_of: :address, dependent: :destroy

  validates_presence_of :city, :country_name

  STREET_TYPES = YAML.safe_load(
    File.read(Rails.root.join('data', 'street_types.yml'))
  ).to_set.freeze

  def to_s
    "#{street1}, #{street2}, #{street3}, #{city}, #{state_name} #{postal}, #{country_name}".strip.gsub(/\s+,/, " ").gsub(/\s+/, " ")
  end

  def self.parse(str, data = {})
    raise NotImplementedError
  end

  def parse(str = nil)
    raise NotImplementedError
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
      %w(w n e s west north east west nw ne sw se).include?(parts[1].downcase) && !STREET_TYPES.include?(parts[2].downcase)
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
