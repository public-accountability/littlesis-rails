class Document < ActiveRecord::Base
  has_many :references

  validates :url, presence: true
  validates :url_hash, presence: true, uniqueness: true
  validates :name, length: { maximum: 255 }

  before_validation :trim_whitespace, :set_hash

  private

  def trim_whitespace
    self.url.strip! unless url.nil?
    self.name.strip! unless name.nil?
  end

  def set_hash
    self.url_hash = Digest::SHA1.hexdigest(url) unless url.blank?
  end
end
