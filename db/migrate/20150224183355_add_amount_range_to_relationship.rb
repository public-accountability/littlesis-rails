class AddAmountRangeToRelationship < ActiveRecord::Migration
  def change
    add_column :relationship, :amount2, :integer, limit: 8
  end
end
