class Document < ActiveRecord::Base
  has_many :references
  validates_presence_of :url, :url_hash
  validates :name, length: { maximum: 255 }

  # before_create :trim_whitespace, :set_hash
  
  private

  # def trim_whitespace
  # end

  # def set_hash
  # end

end
