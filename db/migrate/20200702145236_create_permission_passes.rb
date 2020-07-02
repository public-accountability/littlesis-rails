# frozen_string_literal: true

class CreatePermissionPasses < ActiveRecord::Migration[6.0]
  def change
    create_table :permission_passes do |t|
      t.string :event_name
      t.string :token, null: false
      t.datetime :valid_from, null: false
      t.datetime :valid_to, null: false
      t.text :abilities, null: false
      t.integer :creator_id, null: false

      t.timestamps
    end
  end
end
