class UserUpdateCreatedAtUsingSfGuardUser < ActiveRecord::Migration[6.0]
  def up
    User.unscoped.find_each do |user|
      sf_guard_user_id = user.sf_guard_user_id

      if sf_guard_user_id.blank?
        Rails.logger.debug "Missing sf_guard_user_id for user \##{user.id}"
        next
      end

      sf_created_at = ApplicationRecord.execute_sql(<<~SQL).first&.first
        SELECT created_at FROM sf_guard_user where id = #{sf_guard_user_id}
      SQL

      if sf_created_at.present? && sf_created_at < user.created_at
        Rails.logger.debug "Updating created_at for user \##{user.id}"
        user.update_columns(created_at: sf_created_at)
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
