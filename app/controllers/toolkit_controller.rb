class ToolkitController < ApplicationController
  layout 'toolkit'
  before_action :authenticate_user! # except: [:display, :index]
  before_action :admins_only, only: [:new_page, :create_new_page, :edit, :update]
  before_action :set_toolkit_page, only: [:display, :edit]

  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                     autolink: true, fenced_code_blocks: true)

  # GET /toolkit/:toolkit_page
  def display
    @data = markdown(@toolkit_page.markdown)
  end

  # GET /toolkit/:toolkit_page/edit
  def edit
  end

  # GET /toolkit
  def index
    @toolkit_page = ToolkitPage.find_by_name('index')
    if @toolkit_page && !@toolkit_page.markdown.nil?
      @data = markdown(@toolkit_page.markdown)
    else
      @data = markdown("The toolkit page named 'index' will be used as the front page.")
    end
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

  # PATCH /toolkit/:id
  def update
    @toolkit_page = ToolkitPage.find(params[:id])
    if @toolkit_page.update(update_params)
      redirect_to toolkit_display_url(toolkit_page: @toolkit_page.name)
    else
      render :edit
    end
  end

  private

  def set_toolkit_page
    raise Exceptions::NotFoundError if params[:toolkit_page].blank?
    page_name = ToolkitPage.pagify_name(params[:toolkit_page])
    @toolkit_page = ToolkitPage.find_by_name(page_name)
    raise Exceptions::NotFoundError if @toolkit_page.nil?
  end

  def markdown(data)
    ToolkitController::MARKDOWN.render(data)
  end

  def update_params
    params.require(:toolkit_page).permit(:title, :markdown).merge(last_user_id: current_user.id)
  end

  def new_page_params
    params.require(:toolkit_page).permit(:name, :title).merge(last_user_id: current_user.id)
  end
end
