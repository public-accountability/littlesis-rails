class Article < ActiveRecord::Base
  has_many :article_entities, inverse_of: :article, dependent: :destroy
  has_many :entities, through: :article_entities, inverse_of: :articles

  validates_presence_of :title
  validates :url, url: true
end