# frozen_string_literal: true

class LegacyAddress < ApplicationRecord
  self.table_name = 'address'
  include SoftDelete

  belongs_to :entity, inverse_of: :addresses
  belongs_to :state, class_name: "AddressState", inverse_of: :addresses, optional: true
  # has_many :images, inverse_of: :address, dependent: :destroy

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

  def same_as?(address)
    to_s == address.to_s
  end
end
