class CreateDocumentAndReferences < ActiveRecord::Migration
  def self.up
    create_table :documents do |t|
      t.string "name", limit: 255
      t.text "url", limit: 65535, null: false
      t.string "url_hash", limit: 40, null: false
      t.string "publication_date", limit: 10
      t.integer "ref_type", limit: 4, default: 1, null: false
      t.text "excerpt", limit: 16.megabytes - 1

      t.timestamps null: false
      t.index :url_hash, unique: true
    end

    create_table :references do |t|
      t.integer :document_id, null: false, limit: 8
      t.integer :referenceable_id, null: false, limit: 8
      t.string :referenceable_type, nulll: false

      t.timestamps null: false
      t.index [:referenceable_id, :referenceable_type]
    end
  end

  def self.down
    drop_table :documents
    drop_table :references
  end

end
