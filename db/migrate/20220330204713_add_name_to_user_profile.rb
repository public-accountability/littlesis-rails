class AddNameToUserProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :user_profiles, :name, :text

    reversible do |dir|
      dir.up do
        UserProfile.find_each do |user_profile|
          user_profile.update_columns(name: user_profile.full_name)
        end
      end
    end
  end
end
