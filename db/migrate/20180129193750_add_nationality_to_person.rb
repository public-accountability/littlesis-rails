class AddNationalityToPerson < ActiveRecord::Migration[5.0]
  def change
    add_column :person, :nationality, :text
  end
end
