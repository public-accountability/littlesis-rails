class RemoveUrlNullConstraintOnDocuments < ActiveRecord::Migration[6.0]
  def change
    change_column_null :documents, :url, true
    change_column_null :documents, :url_hash, true
  end
end
