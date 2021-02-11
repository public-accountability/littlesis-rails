# frozen_string_literal: true

# Takes a list of Entity ids and gathers the most recent   references for those entities
module RecentEntityReferencesQuery
  def self.run(input, page: 1, per_page: 10)
    entity_ids = if input.is_a?(Entity)
                   [input.id]
                 else
                   input
                 end

    Document.find_by_sql Reference
                           .select('documents.*')
                           .joins(:document)
                           .where(referenceable_type: 'Entity', referenceable_id: entity_ids)
                           .order('"references"."created_at" DESC')
                           .page(page)
                           .per(per_page)
                           .to_sql
  end
end
