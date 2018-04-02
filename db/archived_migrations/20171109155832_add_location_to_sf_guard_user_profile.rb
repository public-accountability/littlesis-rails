class AddLocationToSfGuardUserProfile < ActiveRecord::Migration
  def change
    add_column :sf_guard_user_profile, :location, :string
  end
end
