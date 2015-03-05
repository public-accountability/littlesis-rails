class ArticleEntity < ActiveRecord::Base
  belongs_to :article, inverse_of: :article_entities
  belongs_to :entity, inverse_of: :article_entities
end