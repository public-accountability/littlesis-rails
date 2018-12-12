class ConvertNetworkMapUserIdToUseRailsId < ActiveRecord::Migration[5.2]
  def up
    NetworkMap.unscoped.find_each do |network_map|
      user_id = User.find_by(sf_guard_user_id: network_map.sf_user_id)&.id

      if user_id.nil?
        warning = "[ConvertNetworkMapUserIdToUseRailsId] cannot find with user sf_guard_user_id: #{network_map.sf_user_id}"
        ColorPrinter.print_red warning
        Rails.logger.warn warning
      else
        network_map.update_column(:user_id, user_id)
      end
    end
  end

  def down
    ApplicationRecord.execute_sql <<-SQL
      UPDATE network_map
      SET user_id = sf_user_id
    SQL
  end
end
