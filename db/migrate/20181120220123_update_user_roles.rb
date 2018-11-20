class UpdateUserRoles < ActiveRecord::Migration[5.2]
  def up

    admins = User.joins(<<SQL)
INNER JOIN sf_guard_user_permission ON 
           sf_guard_user_permission.user_id = users.sf_guard_user_id AND
           sf_guard_user_permission.permission_id = 1
SQL

    raise "There shouldn't be this many admins: #{admins.size}" if admins.size > 20

    admins.each { |a| a.update!(role: :admin) }

    # system users: system, admin, bot, cmp, congress
    User.where(id: [1, 2, 3, 9948, 10040]).update_all(role: :system) unless Rails.env.test?
  end

  def down
    User.update_all(role: :user)
  end
end
