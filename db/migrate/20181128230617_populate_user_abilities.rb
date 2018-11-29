class PopulateUserAbilities < ActiveRecord::Migration[5.2]

  def up
    User.find_each do |user|
      abilities = []
      abilities << :edit unless user.restricted?
      abilities << :delete if user.permissions.deleter?
      abilities << :merge if user.merger?
      abilities << :bulk if user.bulker?
      abilities << :match if user.importer?
      abilities << :admin if user.admin?
      user.add_ability(*abilities) unless abilities.length.zero?
    end
    
  end

  def down
    ApplicationRecord.execute_sql("UPDATE users SET abilities = NULL")
  end
end
