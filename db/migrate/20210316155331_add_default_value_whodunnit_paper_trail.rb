class AddDefaultValueWhodunnitPaperTrail < ActiveRecord::Migration[6.1]
  def change
    change_column_default :versions, :whodunnit, from: nil, to: "1"
  end
end
