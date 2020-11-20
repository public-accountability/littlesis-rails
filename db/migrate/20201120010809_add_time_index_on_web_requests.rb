class AddTimeIndexOnWebRequests < ActiveRecord::Migration[6.0]
  def change
    add_index :web_requests, :time
  end
end
