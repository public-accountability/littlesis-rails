class RemoveExtensionRecordLastUserForeignKey < ActiveRecord::Migration[6.0]
  def change
  	remove_foreign_key :extension_record, :sf_guard_user
  end
end
