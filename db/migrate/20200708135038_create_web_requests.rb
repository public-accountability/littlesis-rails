class CreateWebRequests < ActiveRecord::Migration[6.0]
  def change
    create_table :web_requests do |t|
      t.string :remote_address
      t.datetime :time
      t.string :host
      t.string :http_method
      t.text :uri
      t.integer :status, limit: 2
      t.integer :body_bytes
      t.float :request_time
      t.text :referer
      t.text :user_agent
      t.string :request_id, index: { unique: true }, null: false
    end
  end
end
