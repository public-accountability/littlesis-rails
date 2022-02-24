# frozen_string_literal: true

class PagesController < ApplicationController
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :edit_by_name, :index, :show]
  before_action :admins_only, only: [:new, :create, :edit, :update, :edit_by_name, :index, :show]
  before_action :set_page_by_name, only: [:display, :edit_by_name]
  before_action :set_page_by_id, only: [:show, :edit]

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

  ## ^^ editable pages

  ## pages with translations stored in config/pages

  def disclaimer
    @title = I18n.locale == :es ? 'Descargo de responsabilidad' : 'Disclaimer'
    @content = Pages.get(:disclaimer, I18n.locale)
    render :page
  end

  # def about
  #   @title = I18n.locale == :es ? 'Descargo de responsabilidad' : 'Disclaimer'
  #   @content = Pages.get(:disclaimer, I18n.locale)
  #   render :page
  # end

  ## site pages

  # /oligrapher
  def oligrapher
  end

  # /donate
  def donate
  end

  # /swamped
  def swamped
    if request.post?
      SwampTip.create!(content: params[:tip])
      redirect_to :swamped
    else
      expires_in 30.minutes, public: true
      render layout: 'fullscreen'
    end
  end

  # /bulk_data
  def bulk_data
  end

  def public_data
    expires_in 1.week, public: true
    send_file PublicData::DIR.join(params[:file])
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
    params.require(:page).permit(:title, :content).merge(last_user_id: current_user.id)
  end

  def new_page_params
    params.require(:page).permit(:name, :title).merge(last_user_id: current_user.id)
  end
end
