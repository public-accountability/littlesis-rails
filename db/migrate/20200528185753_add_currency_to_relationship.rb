class AddCurrencyToRelationship < ActiveRecord::Migration[6.0]
  def up
    add_column :relationship, :currency, :string, after: :amount

    # Assume all existing financial data is USD
    Relationship.where.not(amount: nil).update_all(currency: 'USD')
  end

  def down
    remove_column :relationship, :currency
  end
end
