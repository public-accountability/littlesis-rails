class AddListCustomField < ActiveRecord::Migration
  def change
    change_table :ls_list do |t|
      t.string :custom_field_name, limit: 100
    end

    change_table :ls_list_entity do |t|
      t.text :custom_field
    end
  end
end
