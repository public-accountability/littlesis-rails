class RemoveEntityLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
    remove_foreign_key :entity, :sf_guard_user
  end
end
