class ToolkitController < ApplicationController
  layout 'toolkit'
  before_action :authenticate_user!, only: [:new_page, :create_new_page]
  before_action :admins_only, only: [:new_page, :create_new_page]

  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true)

  def index
    @data = markdown("# i am markdown\n## display me!")
  end
  
  # GET /toolkit/new
  def new_page
    @toolkit_page = ToolkitPage.new
  end

  # POST /toolkit/create_new_page
  def create_new_page
    @toolkit_page = ToolkitPage.new(new_page_params)
    if @toolkit_page.save
      redirect_to toolkit_path
    else
      render :new_page
    end
  end

  private

  def markdown(data)
    ToolkitController::MARKDOWN.render(data)
  end

  def new_page_params
    params.require(:toolkit_page).permit(:name, :title).merge(last_user_id: current_user.id)
  end
end
