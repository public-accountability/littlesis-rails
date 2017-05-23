module SimilarRelationships
  extend ActiveSupport::Concern

  module ClassMethods
    # input: Hash with fields: entity1_id, entity2_id, category_id
    #        OR
    #        string/int, string/int, string/int
    # output: []
    def find_similar(hash_or_entity1_id, entity2_id = nil, category_id = nil)
      if hash_or_entity1_id.is_a? Hash
        entity1_id = hash_or_entity1_id.fetch 'entity1_id'
        entity2_id = hash_or_entity1_id.fetch 'entity2_id'
        category_id = hash_or_entity1_id.fetch 'category_id'
      else
        entity1_id = hash_or_entity1_id
      end
      SimilarRelationships.similar_links(entity1_id, entity2_id, category_id)
    end
  end

  def find_similar
    SimilarRelationships.similar_links(entity1_id, entity2_id, category_id)
  end

  def self.similar_links(entity1_id, entity2_id, category_id)
    Link
      .includes(:relationship)
      .where(
        entity1_id: entity1_id,
        entity2_id: entity2_id,
        category_id: category_id
      )
      .limit(5)
      .map(&:relationship)
  end
end
