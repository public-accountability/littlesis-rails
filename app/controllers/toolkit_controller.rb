class ToolkitController < ApplicationController
  layout 'toolkit'

  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

  def index
    @data = markdown("# i am markdown\n## display me!")
  end

  private

  def markdown(data)
    ToolkitController::MARKDOWN.render(data)
  end

end
