class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :edit_by_name, :index, :show]
  before_action :admins_only, only: [:new, :create, :edit, :update, :edit_by_name, :index, :show]
  before_action :set_page_by_name, only: [:display, :edit_by_name]
  before_action :set_page_by_id, only: [:show, :edit]

  MARKDOWN = Redcarpet::Markdown.new(Redcarpet::Render::HTML,
                                     autolink: true, fenced_code_blocks: true)

  # GET Pages
  def index
    @pages = Page.select('name, title, id, updated_at, created_at, last_user_id').all
  end

  # GET /:page
  def display
  end

  def show
    render 'display'
  end

  # GET /pages/new
  def new
    @page = Page.new
  end

  # POST /pages
  def create
    @page = Page.new(new_page_params)
    if @page.save
      redirect_to home_path
    else
      render :new
    end
  end

  def edit_by_name
    redirect_to edit_page_path(@page)
  end

  # GET /pages/123/edit
  def edit
  end

  # patch /pages/123
  def update
    @page = Page.find(params[:id])
    if @page.update(update_params)
      redirect_to "/#{@page.name}"
    else
      render :edit
    end
  end

  # GET /oligrapher
  def oligrapher
  end


  # GET /oligrapher
  # Oligrapher splash page
  def oligrapher_splash
    @maps = NetworkMap.featured.order("updated_at DESC, id DESC").page(params[:page]).per(50)

    @fcc_map = NetworkMap.find(101)
    @lawmaking_map = NetworkMap.find(542)
    @ferguson_map = NetworkMap.find(259)

    @shale_map = NetworkMap.find(152)
    @hadley_map = NetworkMap.find(238)
    @moma_map = NetworkMap.find(282)
    render layout: 'splash'
  end

  def partypolitics
    response.headers.delete('X-Frame-Options')
    render layout: "fullscreen"
  end

  def donate
  end

  private

  def set_page_by_id
    @page = Page.find(params[:id])
  end

  def set_page_by_name
    page_name = Page.pagify_name(params[:page])
    @page = Page.find_by_name(page_name)
    raise Exceptions::NotFoundError if @page.nil?
  end

  def update_params
    params.require(:page).permit(:title, :markdown).merge(last_user_id: current_user.id)
  end

  def new_page_params
    params.require(:page).permit(:name, :title).merge(last_user_id: current_user.id)
  end
end
