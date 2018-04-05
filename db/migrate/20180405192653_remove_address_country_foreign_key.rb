class RemoveAddressCountryForeignKey < ActiveRecord::Migration[5.1]
  def change
    remove_foreign_key :address_state, :address_country
  end
end
