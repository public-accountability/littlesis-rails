class MigrateHelpPagesToActionText < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.transaction do
      HelpPage.find_each do |page|
        page.update!(content: PagesController::MARKDOWN.render(page.markdown))
      end

      rename_column :help_pages, :markdown, :markdown_deprecated
    end
  end

  def down
    ActiveRecord::Base.transaction do
      rename_column :help_pages, :markdown_deprecated, :markdown 

      HelpPage.find_each do |page|
        page.update!(content: nil)
      end
    end
  end
end
