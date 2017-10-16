class Document < ActiveRecord::Base
  has_many :references

  validates :url, presence: true, url: true
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

  #---------------#
  # CLASS METHODS #
  #---------------#

  # Returns the reference types as an array: [ [name, number], ... ]
  # Removes the FEC filings option
  # Used by the add reference modal in _reference_new.html.erb
  def self.ref_type_options
    REF_TYPES.except(2).map(&:reverse)
  end

  # Retrieve a Document by url
  # input: String
  # output: <Document> | nil
  def self.find_by_url(url)
    raise Exceptions::InvalidUrlError if url.blank? || !valid_url?(url.strip)
    find_by_url_hash url_to_hash(url)
  end

  #-----------------------#
  # PRIVATE CLASS METHODS #
  #-----------------------#

  def self.url_to_hash(url)
    Digest::SHA1.hexdigest(url)
  end

  def self.valid_url?(url)
    URI.parse(url).is_a?(URI::HTTP)
  rescue URI::InvalidURIError
    false
  end

  private_class_method :url_to_hash

  #--------------------------#
  # PRIVATE INSTANCE METHODS #
  #--------------------------#

  private

  def trim_whitespace
    self.url.strip! unless url.nil?
    self.name.strip! unless name.nil?
  end

  def set_hash
    self.url_hash = url_to_hash unless url.blank?
  end

  def url_to_hash
    Document.send(:url_to_hash, url)
  end
end
