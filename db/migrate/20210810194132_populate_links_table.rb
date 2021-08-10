class PopulateLinksTable < ActiveRecord::Migration[6.1]
  def up
    execute <<-SQL
      insert into links (entity1_id, entity2_id, category_id, relationship_id, is_reverse)

      select
        entity1_id,
        entity2_id,
        category_id,
        id,
        false
      from relationships
      where is_deleted = false

      union

      select
        entity2_id as entity1_id,
        entity1_id as entity2_id,
        category_id,
        id,
        true
      from relationships
      where is_deleted = false
    SQL
  end
end
