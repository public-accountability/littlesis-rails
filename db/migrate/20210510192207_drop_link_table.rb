class DropLinkTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :link
  end
end
