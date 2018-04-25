# frozen_string_literal: true

class ListHistory < RecordHistory
  model_name :list

  def versions_sql(select: '*', order: 'ORDER BY created_at DESC')
    <<~SQL
      SELECT #{select}
      FROM versions
      WHERE (item_id = #{list.id} AND item_type = 'List')
         OR (other_id = #{list.id} AND item_type = 'ListEntity')
      #{order}
    SQL
  end
end
