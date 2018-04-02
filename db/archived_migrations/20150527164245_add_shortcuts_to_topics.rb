class AddShortcutsToTopics < ActiveRecord::Migration
  def change
    add_column :topics, :shortcuts, :text
  end
end
