class DropLinksView < ActiveRecord::Migration[6.1]
  def change
    drop_view :links, materialized: true
  end
end
