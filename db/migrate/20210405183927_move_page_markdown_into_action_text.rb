class MovePageMarkdownIntoActionText < ActiveRecord::Migration[6.1]
  def up
    ActiveRecord::Base.transaction do
      Page.find_each do |page|
        page.update!(content: PagesController::MARKDOWN.render(page.markdown))
      end

      rename_column :pages, :markdown, :markdown_deprecated
    end
  end

  def down
    ActiveRecord::Base.transaction do
      rename_column :pages, :markdown_deprecated, :markdown 

      Page.find_each do |page|
        page.update!(content: nil)
      end
    end
  end
end
