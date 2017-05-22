module SimilarRelationships
  def find_similar
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
