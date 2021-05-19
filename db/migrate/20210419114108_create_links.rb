class CreateLinks < ActiveRecord::Migration[6.1]
  def up
    create_view :links, materialized: true
    add_index :links, [:entity1_id, :entity2_id, :relationship_id]

    # Needed for use as primary key, so we can still perform find etc on the model
    add_index :links, :id, unique: true

    # Also needed separately as a prerequisite for concurrent refreshes of the view
    execute <<~SQL
      CREATE UNIQUE INDEX ON links (relationship_id, is_reverse)
    SQL
  end

  def down
    drop_view :links, materialized: true
  end
end
