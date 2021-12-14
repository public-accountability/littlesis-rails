# frozen_string_literal: true

module OligrapherSearchService
  LIMIT = 150

  def self.run(query, user_id: nil, limit: LIMIT)
    query = query&.strip
    tsquery_sql = ApplicationRecord.sanitize_sql_for_assignment(["websearch_to_tsquery(?)", query])

    relation = NetworkMap
                 .select("id, title, updated_at, created_at, is_private, is_featured, user_id, ts_rank(search_tsvector, #{tsquery_sql}) as rank")
                 .where("search_tsvector @@ #{tsquery_sql}")
    if user_id
      relation = relation.where(user_id: user_id).order(Arel.sql("rank DESC"))
    else
      relation = relation.where(is_private: false).order(Arel.sql("is_featured DESC, rank DESC"))
    end

    relation.limit(limit).to_a
  end
end
