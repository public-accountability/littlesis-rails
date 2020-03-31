class RemoveReferenceExcerptLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :reference_excerpt, :sf_guard_user
  	remove_column :reference_excerpt, :last_user_id, :integer
  end
end
