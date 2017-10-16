class Document < ActiveRecord::Base
  has_many :references

  validates :url, presence: true
  validates :url_hash, presence: true, uniqueness: true
  validates :name, length: { maximum: 255 }

  before_validation :trim_whitespace, :set_hash

  REF_TYPES = {
    1 => 'Generic',
    2 => 'FEC Filing',
    3 => 'Newspaper',
    4 => 'Government Document'
  }.freeze

  def ref_types_display
    REF_TYPES[ref_type]
  end

  # Returns the reference types as an array: [ [name, number], ... ]
  # Removes the FEC filings option
  # Used by the add reference modal in _reference_new.html.erb
  def self.ref_type_options
    REF_TYPES.except(2).map(&:reverse)
  end

  private

  def trim_whitespace
    self.url.strip! unless url.nil?
    self.name.strip! unless name.nil?
  end

  def set_hash
    self.url_hash = Digest::SHA1.hexdigest(url) unless url.blank?
  end
end
