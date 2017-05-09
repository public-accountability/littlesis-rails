module PagesHelper
  def render_markdown(data)
    PagesController::MARKDOWN.render(data)
  end
end
