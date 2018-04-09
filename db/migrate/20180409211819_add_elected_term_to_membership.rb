class AddElectedTermToMembership < ActiveRecord::Migration[5.1]
  def change
    add_column :membership, :elected_term, :text
  end
end
