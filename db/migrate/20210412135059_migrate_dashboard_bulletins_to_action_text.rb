class MigrateDashboardBulletinsToActionText < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.transaction do
      DashboardBulletin.find_each do |page|
        page.update!(content: PagesController::MARKDOWN.render(page.markdown))
      end

      rename_column :dashboard_bulletins, :markdown, :markdown_deprecated
    end
  end

  def down
    ActiveRecord::Base.transaction do
      rename_column :dashboard_bulletins, :markdown_deprecated, :markdown 

      DashboardBulletin.find_each do |page|
        page.update!(content: nil)
      end
    end
  end
end
