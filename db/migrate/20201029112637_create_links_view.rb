class CreateLinksView < ActiveRecord::Migration[6.0]
  def change
    create_view :links_view
  end
end
