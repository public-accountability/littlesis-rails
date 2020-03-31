class RemoveSfGuardUserProfile < ActiveRecord::Migration[6.0]
  def change
    if ActiveRecord::Base.connection.tables.include? 'sf_guard_user_profile'
      drop_table :sf_guard_user_profile
    end
  end
end
